# nitpick-skills

Plugin and skill for installing and using [nitpick](https://github.com/LVTD-LLC/nitpick), AI code review for AI agents, inside coding-agent harnesses: Claude Code, OpenAI Codex, Cursor, OpenClaw, OpenCode, pi, and anything else that reads Agent Skills.

Two things ship here. **Hooks** that make nitpick review in the background while the agent works: each batch of edits is reviewed by a different model and findings reach the agent as a `[nitpick]` note, with a stop hook that sends the agent back for anything high or blocker. And a **skill** that teaches the agent to install nitpick, run it before opening a PR, and act on findings.

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

1. Install the binary if `nitpick --version` fails:
   ```bash
   brew install LVTD-LLC/tap/nitpick
   ```
   or, without Homebrew, `cargo install --git https://github.com/LVTD-LLC/nitpick` (needs Rust 1.98+).
2. Install this skill into your harness using the matching section below, or run `./install.sh` from a clone of this repo, which does step 1 and links the skill into `~/.agents/skills/` and `~/.claude/skills/`.
3. Make sure `NITPICK_OPENROUTER_API_KEY` is exported, or a local Ollama / llama.cpp server is running. Ask the user if neither is true. Never write the key into a file.
4. If you installed a plugin in Claude Code or Codex, the background-review hooks are already in place (Codex asks the user to trust them once via `/hooks`). Otherwise run `nitpick watch install <harness>` for the harness you are in.
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
```

Or open `/plugins` in a Codex session and install **nitpick** from the browser. Codex runs plugin hooks only after you trust them: run `/hooks` once in a session. Codex also reads skills from `~/.agents/skills/`, so `./install.sh` works as an alternative; add the hooks with `nitpick watch install codex`.

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
