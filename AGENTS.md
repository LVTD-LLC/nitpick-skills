# AGENTS.md

This repository is a plugin and skill for the `nitpick` CLI, packaged so that every major coding-agent harness can install it. There is no code here, only manifests and Markdown.

## Rules

- `plugins/nitpick/skills/nitpick/SKILL.md` is the product. Keep it under 200 lines, concrete, and in sync with the real CLI in `LVTD-LLC/nitpick` (flags, exit codes, env vars, defaults). When nitpick changes its interface, update `SKILL.md` and `plugins/nitpick/skills/nitpick/references/cli.md` in the same change.
- Every manifest must carry the same `name` (`nitpick`) and the same `version`. Bump the version everywhere at once: the four manifests under `plugins/nitpick/`, the entry in `.claude-plugin/marketplace.json`, and `metadata.version` in `SKILL.md`.
- Keep the repo valid in all formats. Do not add components that only one harness understands unless they are harmless to the others (a `hooks/` directory, for example, would be read by Claude Code and Codex with different semantics).
- Keep client-specific data in `plugin.json` under `extensions` with a reverse-domain key; the Agent Plugins spec allows no other top-level fields.

## Checks

Run before committing:

```bash
claude plugin validate .                       # marketplace
claude plugin validate ./plugins/nitpick       # plugin manifest and skill frontmatter
codex plugin marketplace add . && codex plugin list | grep nitpick && codex plugin marketplace remove nitpick-skills
bash -n install.sh && shellcheck install.sh    # if shellcheck is installed
```

To try the plugin live in Claude Code without installing: `claude --plugin-dir ./plugins/nitpick` then `/nitpick:nitpick`.

For Codex: `codex plugin marketplace add .` from the repo root, then `/plugins` in a Codex session.

## Git

Commit to `main`. Push to `LVTD-LLC/nitpick-skills`. Tag releases to match nitpick's version when the skill or manifests change materially.
