# Changelog

## 2026-10-06

- 0.3.1: new `nitpick-setup` skill holds the full install and setup flow (the nitpick.sh prompt now just points to it). Claude Code gets its hooks from the plugin only: the docs and `install.sh` no longer offer `nitpick watch install claude`, which registered every hook twice; nitpick 0.3.1 also cleans up such a copy by itself.

## 2026-10-02

- 0.2.0: background review. The plugin now ships hooks for Claude Code (`hooks/hooks.json`), Codex (`hooks/codex-hooks.json`) and Cursor (`hooks/cursor-hooks.json`) that drive `nitpick watch`: each batch of the agent's edits is reviewed in the background and findings arrive as `[nitpick]` notes; a stop hook sends the agent back for high or blocker findings. The skill documents both modes and `nitpick watch install` for pi, OpenCode and OpenClaw. `install.sh` offers to install the hooks.

## 2026-09-30

- Initial release: nitpick 0.1.0 plugin for Claude Code, Codex, Cursor, OpenClaw, OpenCode and any Agent Skills client.
