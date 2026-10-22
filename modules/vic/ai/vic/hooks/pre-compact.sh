#!/usr/bin/env bash
# PreCompact: hold AUTO compaction below 90% ctx (idle compaction fires at 22-77% and burns the cache).
# Manual, >=90% and unreadable ctx pass. Exit 2 = hold.
set -uo pipefail
in=$(cat 2>/dev/null) || exit 0
[ "$(printf '%s' "$in" | jq -r '.trigger // empty' 2>/dev/null)" = auto ] || exit 0
tp=$(printf '%s' "$in" | jq -r '.transcript_path // empty' 2>/dev/null)
[ -s "$tp" ] || exit 0
tok=$(tail -n 400 "$tp" | jq -Rr 'fromjson? | select(.type == "assistant" and .isSidechain != true)
  | .message.usage? // empty
  | (.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0)' 2>/dev/null | tail -n 1)
case "$tok" in "" | *[!0-9]*) exit 0 ;; esac
# window 200K as in ctx-meter.sh
if [ $((tok * 100 / 200000)) -lt 90 ]; then
  echo "auto compaction held at ctx $((tok * 100 / 200000))%: below the 90% close-out gate" >&2
  exit 2
fi
exit 0
