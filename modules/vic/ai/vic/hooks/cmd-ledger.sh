#!/usr/bin/env bash
# GLOBAL PostToolUse(Bash): every command + FULL output → per-project ledger.
# Kills re-run-for-longer-tail waste. Query: vic-recall. Fail-open, zero stdout.
p="${CLAUDE_PROJECT_DIR:-$PWD}"
k=$(printf '%s' "$p" | sed 's|/|-|g')
d="$HOME/.cache/claude-ledger/$k"
mkdir -p "$d" 2>/dev/null || exit 0
jq -c '{ts: now|todate, sid: (.session_id // "?"), cmd: (.tool_input.command // ""),
        out: ((.tool_response.stdout // .tool_response.output // (.tool_response|tostring) // "")[0:60000]),
        err: ((.tool_response.stderr // "")[0:8000])}' >> "$d/bash-$(date +%Y%m%d).jsonl" 2>/dev/null
exit 0
