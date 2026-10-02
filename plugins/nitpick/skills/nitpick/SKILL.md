---
name: nitpick
description: Get an independent AI code review of your changes with the nitpick CLI (a different model on OpenRouter or a local model, with repo context pulled in automatically). Two modes. On demand: run `nitpick` after finishing a change, before committing or creating a PR, when the user asks to "review my changes", "run nitpick", or "get a second opinion on this diff". In the background: `nitpick watch` hooks into this harness and reviews each batch of edits while you work, delivering findings as "[nitpick]" notes; use this skill when such a note appears, when the user asks to "set up nitpick watch" or "review in the background", or to check `nitpick watch status`. Also covers installing nitpick and fixing a failed review.
license: MIT
compatibility: Requires git and the nitpick binary (installs via Homebrew or cargo). Needs NITPICK_OPENROUTER_API_KEY, or a local Ollama / llama.cpp server.
metadata:
  author: LVTD-LLC
  version: "0.2.0"
  homepage: https://nitpick.sh
---

# nitpick: second-opinion code review

`nitpick` sends the git diff, the full changed files, and the relevant code from the rest of the repo (definitions the diff uses, call sites of what it changed, imports, matching tests) to a model you did not write the code with, and prints structured findings. Exit code 1 means there are findings at or above `--fail-on` (default `high`). You run it, fix what it finds, and run it again until it exits 0.

It also runs by itself. With `nitpick watch` installed into this harness's hooks, every batch of edits you make is reviewed in the background and anything it finds reaches you as a note that starts with `[nitpick]`. Section 6 covers that.

## 1. Make sure it is installed

```bash
nitpick --version
```

If that fails, install it. Prefer Homebrew; fall back to cargo. Do not build from a git clone by hand.

```bash
brew install LVTD-LLC/tap/nitpick      # macOS or Linux with Homebrew
cargo install --git https://github.com/LVTD-LLC/nitpick   # any platform with Rust 1.98+
```

If neither `brew` nor `cargo` exists, tell the user which one to install and stop; do not try to compile Rust from scratch.

## 2. Make sure it can reach a model

nitpick needs one of:

- `NITPICK_OPENROUTER_API_KEY` or `OPENROUTER_API_KEY` in the environment (OpenRouter, the default provider).
- A local server: `--provider ollama` (http://localhost:11434) or `--provider llamacpp` (http://localhost:8080), no key needed.
- Any OpenAI-compatible endpoint: `--provider openai --base-url <url>` with `NITPICK_API_KEY`.

If no key is set and no local server is running, ask the user for a key or a provider. Never paste a key into a file or a commit; export it in the shell or let the user add it to their shell profile.

## 3. Run the review

From the repo root, after your change is complete and the tests pass:

```bash
nitpick
```

By default it reviews the working tree, including untracked files, against the merge-base with the default branch. Other shapes:

```bash
nitpick --staged                 # only what is staged
nitpick --base develop           # different base branch
nitpick --range main..HEAD       # explicit revision range
nitpick src/api/                 # limit to paths
nitpick -f "Focus on the SQL and auth checks."   # extra instructions for the reviewer
nitpick --json                   # machine-readable output
```

Progress goes to stderr, the review to stdout. Reviews take 30 seconds to a few minutes depending on the model. If your harness supports background commands, run it in the background and keep working, but do not open the PR until it finishes.

## 4. Act on the result

- **Exit 0**: no findings at or above the threshold. Proceed.
- **Exit 1**: read every finding. Each one cites `path:line` in the post-change file, a severity, a category, an explanation, and usually a suggestion.
  - Fix every `blocker` and `high` finding, then run `nitpick` again. Repeat until it exits 0.
  - `medium` and below are judgment calls. Fix them if cheap and clearly right; otherwise leave them and mention them in the commit message or PR description.
  - If a finding is wrong, say so explicitly with a one-line reason where a reviewer will see it. Do not lower `--fail-on` or add `--no-context` to make it pass.
- **Exit 2**: the tool could not run (no changes, no key, every model failed). Read the error. Provider errors (429, 503, empty responses) are transient; rerun once, or pass a different `-m <model>`. Do not treat this as a passing review.

When several models are configured, findings that agree are merged and marked `(2/3 models)`. Agreement is a confidence signal, not a requirement.

## 5. Project configuration

If the repo has a `.nitpick.toml`, respect it; it sets the models, base branch, ignore globs, and reviewer instructions the maintainers want. If it does not and you will run nitpick more than once in this repo, create one:

```bash
nitpick init
```

Then fill in `instructions` with the project's conventions (framework, what to be strict about, what to ignore). See [references/config.md](references/config.md).

## 6. Background review (`nitpick watch`)

When installed, the harness calls `nitpick hook <harness> <event>` from its own lifecycle hooks. After each tool call the hook records the edit and starts a detached worker; the worker waits for ~20 seconds of quiet, diffs each changed file against the copy it reviewed last time, reviews that small diff, and queues findings at or above `medium`. The next hook hands them to you as a `[nitpick]` note. When you try to finish, a stop hook reviews whatever is left and sends you back once or twice if anything is `high` or `blocker`. Nothing is asked of you until a note appears.

**When a `[nitpick]` note appears:** finish the step you are on. Then read each finding: it cites `path:line` in the current file, says what is wrong, and usually suggests a fix. It comes from a different model and can be wrong, so check it against the code before changing anything. Fix the real ones; for a wrong one, say so in one line and move on. Do not stop to re-run anything; the next batch of edits is reviewed the same way.

**When the stop hook sends you back:** the note lists only findings at or above the stop threshold. Fix each, or state in one line why it is wrong, then finish again. The hook gives up after two rounds, so this cannot loop forever.

**Setting it up** (if the Claude Code or Codex plugin is installed, the hooks are already there; Codex users must trust them once with `/hooks`):

```bash
nitpick watch install claude      # or codex, cursor, pi, opencode, openclaw; add --global for every repo
nitpick watch status              # on or off, worker state, what is waiting, recent activity
```

The install writes into the harness's hook file in this repo (`.claude/settings.json`, `.codex/hooks.json`, `.cursor/hooks.json`, `.pi/extensions/`, `.opencode/plugins/`, `.openclaw/extensions/`). Mention to the user that these files exist and let them decide whether to commit them. If `nitpick watch status` says a review failed, the usual cause is a missing API key in the hook's environment; `~/.config/nitpick/config.toml` with `api_key = "..."` fixes that for GUI-launched agents (ask the user to write it; never write a key yourself).

Other useful commands: `nitpick watch log` (every past background finding), `nitpick watch run` (review everything unreviewed right now, in the foreground), `nitpick watch reset`, `NITPICK_WATCH=0` to turn it off for a session. Tune `debounce_secs`, `deliver`, `fail_on`, `model` in the `[watch]` section of `.nitpick.toml`; a free model is a reasonable choice there since reviews are small and frequent.

## Troubleshooting

- `nitpick context` prints exactly what would be sent to the model, with no network call. Use it to check that the right files and context were selected.
- `nitpick context --json` shows the token budget and which snippets were kept or dropped.
- `NITPICK_DEBUG_DIR=/tmp/nitpick-debug nitpick -v` writes every request and raw response to that directory.
- A huge diff blows the context budget; review in parts with paths, or raise `--budget`.
- `nitpick watch status` shows whether watch is enabled, whether a worker is running, which files are waiting, and the last log lines (`<git-dir>/nitpick/log` has all of them).

Full flag list: [references/cli.md](references/cli.md). Source and issues: https://github.com/LVTD-LLC/nitpick
