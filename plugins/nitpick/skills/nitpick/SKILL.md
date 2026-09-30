---
name: nitpick
description: Get an independent AI code review of your uncommitted or unpushed changes before opening a pull request, using the nitpick CLI (a different model on OpenRouter or a local model, with repo context pulled in automatically). Use after finishing a code change, before committing or creating a PR, when the user asks to "review my changes", "run nitpick", "get a second opinion on this diff", or when a task says to review before shipping. Also covers installing nitpick and fixing a failed review.
license: MIT
compatibility: Requires git and the nitpick binary (installs via Homebrew or cargo). Needs NITPICK_OPENROUTER_API_KEY, or a local Ollama / llama.cpp server.
metadata:
  author: LVTD-LLC
  version: "0.1.0"
  homepage: https://nitpick.sh
---

# nitpick: second-opinion code review

`nitpick` sends the git diff, the full changed files, and the relevant code from the rest of the repo (definitions the diff uses, call sites of what it changed, imports, matching tests) to a model you did not write the code with, and prints structured findings. Exit code 1 means there are findings at or above `--fail-on` (default `high`). You run it, fix what it finds, and run it again until it exits 0.

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

## Troubleshooting

- `nitpick context` prints exactly what would be sent to the model, with no network call. Use it to check that the right files and context were selected.
- `nitpick context --json` shows the token budget and which snippets were kept or dropped.
- `NITPICK_DEBUG_DIR=/tmp/nitpick-debug nitpick -v` writes every request and raw response to that directory.
- A huge diff blows the context budget; review in parts with paths, or raise `--budget`.

Full flag list: [references/cli.md](references/cli.md). Source and issues: https://github.com/LVTD-LLC/nitpick
