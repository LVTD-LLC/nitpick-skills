# Changelog

## 2026-10-02

- 0.2.0: background review. The plugin now ships hooks for Claude Code (`hooks/hooks.json`), Codex (`hooks/codex-hooks.json`) and Cursor (`hooks/cursor-hooks.json`) that drive `nitpick watch`: each batch of the agent's edits is reviewed in the background and findings arrive as `[nitpick]` notes; a stop hook sends the agent back for high or blocker findings. The skill documents both modes and `nitpick watch install` for pi, OpenCode and OpenClaw. `install.sh` offers to install the hooks.

## 2026-09-30

- Initial release: nitpick 0.1.0 plugin for Claude Code, Codex, Cursor, OpenClaw, OpenCode and any Agent Skills client.
