#!/usr/bin/env bash
set -uo pipefail
snap="${CLAUDE_ENV_FILE:-$HOME/.claude/direnv-snapshot.sh}"
mkdir -p "$(dirname "$snap")"
# No .envrc: keep the last snapshot so tools don't vanish mid-task.
[ -e .envrc ] || exit 0
command -v direnv >/dev/null || exit 0
tmp="$(mktemp)"
# temp+mv: a half-written snapshot would be sourced by every later shell.
if direnv export bash 2>/dev/null > "$tmp"; then
  mv "$tmp" "$snap"
else
  rm -f "$tmp"
fi
exit 0
