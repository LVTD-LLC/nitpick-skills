---
name: nitpick-setup
description: Install and set up nitpick, AI code review for AI agents, for this user in the harness you are running in (Claude Code, Codex, Cursor, pi, OpenCode, OpenClaw, or any Agent Skills client). Use when the user asks to "set up nitpick", "install nitpick", pastes the nitpick.sh setup prompt, or wants nitpick to review their agent's work in the background. Installs the CLI and the plugin or skill, configures model access, turns on background review in every workspace, and verifies it works.
license: MIT
metadata:
  author: LVTD-LLC
  version: "0.3.1"
  homepage: https://nitpick.sh
---

# Set up nitpick

Goal: after this, every new session of this harness reviews the agent's edits in the background, and the agent runs `nitpick` before opening a pull request. Set it up for the user (globally), not just this folder, unless the user asks for one project only.

Do the steps in order. Keep the user informed in a line or two per step; ask only where a step says to.

## 1. Install or upgrade the CLI

```bash
nitpick --version && nitpick watch --help
```

- Absent: `brew install LVTD-LLC/tap/nitpick`. Without Homebrew (needs Rust 1.98+): `cargo install --git https://github.com/LVTD-LLC/nitpick`. If neither `brew` nor `cargo` exists, tell the user to install one and stop.
- Present: upgrade it, since an old binary still runs: `brew update && brew upgrade nitpick`, or `cargo install --git https://github.com/LVTD-LLC/nitpick --force`.

## 2. Install nitpick into this harness

Use exactly one line, for the harness you are running in.

| Harness | Install | Background hooks |
|---|---|---|
| Claude Code | `claude plugin marketplace add LVTD-LLC/nitpick-skills && claude plugin install nitpick@nitpick-skills` | included in the plugin; run nothing else |
| Codex | `codex plugin marketplace add LVTD-LLC/nitpick-skills && codex plugin add nitpick@nitpick-skills` | `nitpick watch install codex --global` |
| Cursor | `git clone https://github.com/LVTD-LLC/nitpick-skills ~/.local/share/nitpick-skills && ~/.local/share/nitpick-skills/install.sh` | `nitpick watch install cursor --global` |
| OpenClaw | `openclaw plugins install git:github.com/LVTD-LLC/nitpick-skills@main` | `nitpick watch install openclaw --global`, then do what it prints |
| pi, OpenCode, other | the same `git clone ... && install.sh` line as Cursor | `nitpick watch install <pi\|opencode> --global` |

Claude Code: never run `nitpick watch install claude` when the plugin is installed. The plugin already registers the hooks; a second copy makes every hook run twice. (Newer nitpick refuses and cleans up such a copy by itself.)

If the clone directory already exists, `git -C ~/.local/share/nitpick-skills pull` instead of cloning.

## 3. Give it access to a model

nitpick sends each change to a different model, through OpenRouter by default.

- Check what exists: `NITPICK_OPENROUTER_API_KEY` or `OPENROUTER_API_KEY` in the environment, or `api_key` in `~/.config/nitpick/config.toml`. A local Ollama (`localhost:11434`) or llama.cpp (`localhost:8080`) server needs no key.
- Hooks in apps launched from the Dock or Start menu often do not see shell exports, so the key must be in the config file for background review. If it is only in the shell, ask the user before copying it there.
- No key at all: ask the user for an OpenRouter key (https://openrouter.ai/keys) or which local server to use.
- Never print a key, echo it into a command line, or write it inside a repository.

Write the user-level config (merge with an existing file; do not drop its other settings):

```toml
# ~/.config/nitpick/config.toml
api_key = "sk-or-..."

[watch]
model = "nvidia/nemotron-3-ultra-550b-a55b:free"   # free; background reviews are small and frequent
```

Then `chmod 600 ~/.config/nitpick/config.toml`. For a local server, set `provider = "ollama"` (or `"llamacpp"`) and a `model` instead of `api_key`.

## 4. Codex only: enable and trust the hooks

Tell the user to restart Codex, open `/hooks` (or Hooks in the desktop app settings), and under **User config** both enable and trust the four nitpick hooks. They are separate switches. Do not bypass trust or write approval hashes yourself.

## 5. Verify it really works

Install is not activation. Prove it end to end:

1. `nitpick` in any git repo with a change: a review must come back (exit 0 or 1). Exit 2 means it could not reach the model; fix step 3 first.
2. In a fresh session of this harness, in another workspace, make a small edit, wait ~30 seconds, and run `nitpick watch status`: it must show a completed review in `recent:`. To see a finding delivered, plant an obvious bug, wait for the `[nitpick]` note, then remove the bug.

`enabled: yes`, an installed plugin, or a working terminal review alone does not prove background review is on. If a step could not be verified (for example Codex still needs the user to trust hooks), say exactly which.

## 6. Tell the user what changed

In a few lines: CLI version, how nitpick was installed in this harness, where the key lives (path only), the background model, and anything still pending on their side.

From now on, follow the `nitpick` skill: act on `[nitpick]` notes as they arrive (fix real issues, dismiss wrong ones in a sentence), and run `nitpick` before opening a pull request until it exits 0.
