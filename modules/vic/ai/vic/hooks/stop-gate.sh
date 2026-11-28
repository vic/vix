#!/usr/bin/env bash
# GLOBAL Stop: ctx hot + stale HANDOFF -> block stop once until HANDOFF updated.
# Only enforces in projects WITH vic/ structure. Anti-loop safe. Fail-open.
input=$(cat 2>/dev/null) || exit 0
case "$input" in *'"stop_hook_active":true'*) exit 0 ;; esac
p="${CLAUDE_PROJECT_DIR:-$PWD}"
[ -d "$p/vic" ] || exit 0
tp=$(printf '%s' "$input" | sed -n 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$tp" ] && [ -f "$tp" ] || exit 0
bytes=$(stat -c%s "$tp" 2>/dev/null) || exit 0
pct=$((bytes / 12 * 100 / 200000)); [ "$pct" -gt 99 ] && pct=99
[ "$pct" -lt 70 ] && exit 0
h="$p/vic/HANDOFF.md"
if [ -f "$h" ]; then
  now=$(date +%s); mt=$(stat -c%Y "$h" 2>/dev/null || echo 0)
  [ $((now - mt)) -lt 1800 ] && exit 0
fi
printf '{"decision":"block","reason":"CTX ~%s%% + vic/HANDOFF.md stale: update it per /handoff (<=25 lines: UPDATED/DOING/NEXT-CMD/THEN/OPEN/FILES/BURN), update vic/state.md, then stop. Fresh session resumes from it."}' "$pct"
exit 0
