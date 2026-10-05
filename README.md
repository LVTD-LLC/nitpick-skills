# nitpick-skills

Plugin and skill for installing and using [nitpick](https://github.com/LVTD-LLC/nitpick), AI code review for AI agents, inside coding-agent harnesses: Claude Code, OpenAI Codex, Cursor, OpenClaw, OpenCode, pi, and anything else that reads Agent Skills.

Two things ship here. **Hooks** that make nitpick review in the background while the agent works: each batch of edits is reviewed by a different model and findings reach the agent as a `[nitpick]` note, with an advisory stop hook that returns immediately (blocking on serious findings is opt-in). And a **skill** that teaches the agent to install nitpick, run it before opening a PR, and act on findings.

This repository is one plugin directory that is valid in every format at once:

| Format | Manifest | Read by |
|---|---|---|
| [Agent Plugins 1.0](https://agent-plugins.org) | `plugins/nitpick/plugin.json` | Codex, Cursor, OpenClaw, and other portable-plugin clients |
| Claude Code plugin + marketplace | `plugins/nitpick/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` | Claude Code, claude.ai, Cowork |
| Codex plugin + marketplace | `plugins/nitpick/.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json` | Codex CLI and app |
| Cursor plugin + marketplace | `plugins/nitpick/.cursor-plugin/plugin.json`, `.cursor-plugin/marketplace.json` | Cursor |
| [Agent Skills](https://agentskills.io) | `plugins/nitpick/skills/nitpick/SKILL.md` | every harness above, plus OpenCode and any skills-aware agent |

Hooks are harness-specific and live in `plugins/nitpick/hooks/`: `hooks.json` (Claude Code), `codex-hooks.json` (Codex, referenced from its manifest), `cursor-hooks.json` (Cursor). Each entry just runs `nitpick hook <harness> <event>`; the binary does the rest. For pi, OpenCode and OpenClaw the binary itself installs a small extension: `nitpick watch install pi` and so on.

## If you are an AI agent

Do these in order.

1. Check `nitpick --version` and `nitpick watch --help`. Install the binary if absent:
   ```bash
   brew install LVTD-LLC/tap/nitpick
   ```
   or, without Homebrew, `cargo install --git https://github.com/LVTD-LLC/nitpick` (needs Rust 1.98+).
   If already installed, check for an upgrade with your package manager (`brew update && brew upgrade nitpick` for Homebrew, or rerun `cargo install --git https://github.com/LVTD-LLC/nitpick --force`). A working old binary is not necessarily current.
2. Install this skill into your harness using the matching section below, or run `./install.sh` from a clone of this repo, which does step 1 and links the skill into `~/.agents/skills/` and `~/.claude/skills/`.
3. Configure provider access for the hook environment. GUI apps may not inherit shell exports: the user-level `~/.config/nitpick/config.toml` supports `api_key`, with file mode `600`. Ask the user to configure it, or obtain explicit permission before securely saving an existing key; never print it or put it in a repository. A local Ollama / llama.cpp server needs no key.
4. For Codex, explicitly run `nitpick watch install codex --global`, even after plugin installation. Restart Codex and enable AND trust the four hooks under **User config** in `/hooks` or desktop Hooks settings. Use one active set; disable plugin duplicates or uninstall project-local duplicates after global activation. For other harnesses use `nitpick watch install <harness> --global` (Claude Code already loads the plugin hooks). Omit `--global` only for an explicitly project-only setup.
5. Read [`plugins/nitpick/skills/nitpick/SKILL.md`](plugins/nitpick/skills/nitpick/SKILL.md) and follow it.

## Install per harness

### Claude Code

```bash
claude plugin marketplace add LVTD-LLC/nitpick-skills
claude plugin install nitpick@nitpick-skills
```

Or for one session without installing: `claude --plugin-dir /path/to/nitpick-skills/plugins/nitpick`. The skill is then available as `/nitpick:nitpick` and Claude also uses it on its own when a review is called for. The plugin's hooks start reviewing in the background from the first edit.

### OpenAI Codex

```bash
codex plugin marketplace add LVTD-LLC/nitpick-skills
codex plugin add nitpick@nitpick-skills
nitpick watch install codex --global
```

Or open `/plugins` and install **nitpick**. The plugin installs the skill, but hook discovery from its manifest is not reliable across Codex versions; use the explicit global command above. Restart Codex and enable **and** trust the four entries under **User config** in `/hooks` or the desktop Hooks settings. Codex controls the group title; each new hook includes a descriptive `statusMessage`.

`./install.sh --hooks codex --global` is an alternative that links the skill and installs the same hooks. Installation preserves existing hook definitions and unrelated hooks. It does not grant trust or enable previously disabled entries.

Verify a fresh session in another workspace: an edit should lead to a completed review in `nitpick watch status`; findings should arrive through the next hook. A successful terminal review only proves terminal credentials, and `enabled: yes` only describes nitpick's settings. Do not claim background review is active until the actual harness has fired its hooks and a model has answered.

### Cursor

Open **Customize**, choose **From GitHub Repository**, and enter `LVTD-LLC/nitpick-skills`; the repo carries the `.cursor-plugin/marketplace.json` Cursor expects. Or copy `plugins/nitpick` to `~/.cursor/plugins/local/nitpick` and run **Developer: Reload Window**. Cursor also reads `~/.agents/skills/`, so `./install.sh` works too; add the hooks with `nitpick watch install cursor`.

### OpenClaw

```bash
openclaw plugins install git:github.com/LVTD-LLC/nitpick-skills@main
```

OpenClaw detects the Agent Plugins manifest and imports the skill. Verify with `openclaw plugins inspect nitpick --runtime`. For background review, `nitpick watch install openclaw` writes a native OpenClaw plugin into `.openclaw/extensions/nitpick/`; enable it and grant it `hooks.allowConversationAccess` as the command prints.

### OpenCode

OpenCode has no plugin manifest for skills; it reads `~/.agents/skills/` and `.agents/skills/` in the project. Either:

```bash
git clone https://github.com/LVTD-LLC/nitpick-skills ~/.local/share/nitpick-skills
~/.local/share/nitpick-skills/install.sh
```

or, for one project only, copy `plugins/nitpick/skills/nitpick` to `<project>/.agents/skills/nitpick`. For background review, `nitpick watch install opencode` writes `.opencode/plugins/nitpick.ts`.

### pi

```bash
nitpick watch install pi          # writes .pi/extensions/nitpick.ts; --global for ~/.pi/agent/extensions/
```

pi reads skills from `~/.agents/skills/` as well, so `./install.sh` covers the skill.

### Any other agent

Anything that implements [Agent Skills](https://agentskills.io) can use `plugins/nitpick/skills/nitpick/`. Copy or symlink that directory to wherever the agent looks for skills; `~/.agents/skills/nitpick` is the emerging convention.

## Layout

```
.claude-plugin/marketplace.json            Claude Code marketplace
.agents/plugins/marketplace.json           Codex marketplace
.cursor-plugin/marketplace.json            Cursor marketplace
plugins/nitpick/plugin.json                Agent Plugins manifest (portable)
plugins/nitpick/.claude-plugin/plugin.json Claude Code manifest
plugins/nitpick/.codex-plugin/plugin.json  Codex manifest
plugins/nitpick/.cursor-plugin/plugin.json Cursor manifest
plugins/nitpick/skills/nitpick/SKILL.md    the skill
plugins/nitpick/skills/nitpick/references/ CLI and config reference the skill links to
plugins/nitpick/skills/nitpick/agents/     Codex UI metadata for the skill
plugins/nitpick/hooks/hooks.json           Claude Code hooks (auto-discovered)
plugins/nitpick/hooks/codex-hooks.json     Codex hooks (referenced from .codex-plugin/plugin.json and plugin.json)
plugins/nitpick/hooks/cursor-hooks.json    Cursor hooks (referenced from .cursor-plugin/plugin.json)
install.sh                                 installs the binary, links the skill, offers to install the hooks
```

## Maintaining

See [`AGENTS.md`](AGENTS.md). Validate after any change:

```bash
claude plugin validate .
claude plugin validate ./plugins/nitpick
codex plugin marketplace add . && codex plugin list && codex plugin marketplace remove nitpick-skills
```

## License

MIT
