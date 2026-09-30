# nitpick-skills

Plugin and skill for installing and using [nitpick](https://github.com/LVTD-LLC/nitpick), AI code review for AI agents, inside coding-agent harnesses: Claude Code, OpenAI Codex, Cursor, OpenClaw, OpenCode, and anything else that reads Agent Skills.

This repository is one plugin directory that is valid in every format at once:

| Format | Manifest | Read by |
|---|---|---|
| [Agent Plugins 1.0](https://agent-plugins.org) | `plugins/nitpick/plugin.json` | Codex, Cursor, OpenClaw, and other portable-plugin clients |
| Claude Code plugin + marketplace | `plugins/nitpick/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` | Claude Code, claude.ai, Cowork |
| Codex plugin + marketplace | `plugins/nitpick/.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json` | Codex CLI and app |
| Cursor plugin + marketplace | `plugins/nitpick/.cursor-plugin/plugin.json`, `.cursor-plugin/marketplace.json` | Cursor |
| [Agent Skills](https://agentskills.io) | `plugins/nitpick/skills/nitpick/SKILL.md` | every harness above, plus OpenCode and any skills-aware agent |

The skill teaches the agent to install nitpick, run it before opening a PR, fix what it finds, and rerun until the review is clean.

## If you are an AI agent

Do these in order.

1. Install the binary if `nitpick --version` fails:
   ```bash
   brew install LVTD-LLC/tap/nitpick
   ```
   or, without Homebrew, `cargo install --git https://github.com/LVTD-LLC/nitpick` (needs Rust 1.98+).
2. Install this skill into your harness using the matching section below, or run `./install.sh` from a clone of this repo, which does step 1 and links the skill into `~/.agents/skills/` and `~/.claude/skills/`.
3. Make sure `NITPICK_OPENROUTER_API_KEY` is exported, or a local Ollama / llama.cpp server is running. Ask the user if neither is true. Never write the key into a file.
4. Read [`plugins/nitpick/skills/nitpick/SKILL.md`](plugins/nitpick/skills/nitpick/SKILL.md) and follow it.

## Install per harness

### Claude Code

```bash
claude plugin marketplace add LVTD-LLC/nitpick-skills
claude plugin install nitpick@nitpick-skills
```

Or for one session without installing: `claude --plugin-dir /path/to/nitpick-skills/plugins/nitpick`. The skill is then available as `/nitpick:nitpick` and Claude also uses it on its own when a review is called for.

### OpenAI Codex

```bash
codex plugin marketplace add LVTD-LLC/nitpick-skills
codex plugin add nitpick@nitpick-skills
```

Or open `/plugins` in a Codex session and install **nitpick** from the browser. Codex also reads skills from `~/.agents/skills/`, so `./install.sh` works as an alternative.

### Cursor

Open **Customize**, choose **From GitHub Repository**, and enter `LVTD-LLC/nitpick-skills`; the repo carries the `.cursor-plugin/marketplace.json` Cursor expects. Or copy `plugins/nitpick` to `~/.cursor/plugins/local/nitpick` and run **Developer: Reload Window**. Cursor also reads `~/.agents/skills/`, so `./install.sh` works too.

### OpenClaw

```bash
openclaw plugins install git:github.com/LVTD-LLC/nitpick-skills@main
```

OpenClaw detects the Agent Plugins manifest and imports the skill. Verify with `openclaw plugins inspect nitpick --runtime`.

### OpenCode

OpenCode has no plugin manifest for skills; it reads `~/.agents/skills/` and `.agents/skills/` in the project. Either:

```bash
git clone https://github.com/LVTD-LLC/nitpick-skills ~/.local/share/nitpick-skills
~/.local/share/nitpick-skills/install.sh
```

or, for one project only, copy `plugins/nitpick/skills/nitpick` to `<project>/.agents/skills/nitpick`.

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
install.sh                                 installs the binary and links the skill
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
