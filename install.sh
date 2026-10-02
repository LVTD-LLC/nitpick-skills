#!/usr/bin/env bash
# Installs the nitpick binary, links the nitpick skill where AI coding agents
# look for skills, and optionally installs the background-review hooks for a
# harness. Safe to rerun. Flags: --no-binary, --no-skill, --hooks <harness>
# (claude|codex|cursor|pi|opencode|openclaw; repeatable), --global.
set -euo pipefail

want_binary=1
want_skill=1
want_global=0
hooks=()
prev=""
for arg in "$@"; do
  if [ "$prev" = "--hooks" ]; then hooks+=("$arg"); prev=""; continue; fi
  case "$arg" in
    --no-binary) want_binary=0 ;;
    --no-skill) want_skill=0 ;;
    --hooks) prev="--hooks" ;;
    --global) want_global=1 ;;
    -h|--help)
      sed -n '2,5p' "$0" | sed 's/^# //'; exit 0 ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_src="$here/plugins/nitpick/skills/nitpick"

if [ "$want_binary" = 1 ]; then
  if command -v nitpick >/dev/null 2>&1; then
    echo "nitpick already installed: $(nitpick --version)"
  elif command -v brew >/dev/null 2>&1; then
    echo "installing nitpick with Homebrew (builds from source, a few minutes)..."
    brew install LVTD-LLC/tap/nitpick
  elif command -v cargo >/dev/null 2>&1; then
    echo "installing nitpick with cargo..."
    cargo install --git https://github.com/LVTD-LLC/nitpick
  else
    echo "neither brew nor cargo found. Install Homebrew (https://brew.sh) or Rust (https://rustup.rs), then rerun." >&2
    exit 1
  fi
fi

if [ "$want_skill" = 1 ]; then
  # ~/.agents/skills is read by Codex, Cursor and OpenCode; ~/.claude/skills by Claude Code.
  for dir in "$HOME/.agents/skills" "$HOME/.claude/skills"; do
    mkdir -p "$dir"
    target="$dir/nitpick"
    if [ -L "$target" ] || [ -e "$target" ]; then
      echo "skill already present at $target (left untouched)"
    else
      ln -s "$skill_src" "$target"
      echo "linked skill: $target -> $skill_src"
    fi
  done
fi

if [ "${#hooks[@]}" -gt 0 ]; then
  for h in "${hooks[@]}"; do
    if [ "$want_global" = 1 ]; then nitpick watch install "$h" --global; else nitpick watch install "$h"; fi
  done
fi

echo
if [ -z "${NITPICK_OPENROUTER_API_KEY:-}" ] && [ -z "${OPENROUTER_API_KEY:-}" ]; then
  echo "next: export NITPICK_OPENROUTER_API_KEY=<your OpenRouter key>, or use --provider ollama."
else
  echo "ready. Run 'nitpick' inside any git repo with changes."
fi
if [ "${#hooks[@]}" -eq 0 ]; then
  echo "to review in the background while an agent works: nitpick watch install <claude|codex|cursor|pi|opencode|openclaw> [--global]"
fi
