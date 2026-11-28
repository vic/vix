#!/bin/sh
# ctx-check.sh — Inspect real token usage from transcript JSONL + HANDOFF freshness (POSIX sh)
# Usage: ctx-check.sh [--transcript <path.jsonl>] [--repo <dir>] [--limit 200000]
set -eu

TRANSCRIPT=""
REPO="."
LIMIT=200000

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: ctx-check.sh [--transcript <session.jsonl>] [--repo <dir>] [--limit 200000]

Reads actual latest input+cache token usage from a Claude transcript JSONL (if provided),
falls back to file-size estimate if jq unavailable, and checks <repo>/vic/HANDOFF.md age/lines.
EOF
            exit 0
            ;;
        --transcript) TRANSCRIPT="$2"; shift 2 ;;
        --repo) REPO="$2"; shift 2 ;;
        --limit) LIMIT="$2"; shift 2 ;;
        *) echo "ctx-check: unknown arg: $1" >&2; exit 2 ;;
    esac
done

if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
    TOKENS=0
    if command -v jq >/dev/null 2>&1; then
        TOKENS=$(tac "$TRANSCRIPT" 2>/dev/null | jq -r '
            select(.message.usage != null) |
            ((.message.usage.input_tokens // 0) +
             (.message.usage.cache_creation_input_tokens // 0) +
             (.message.usage.cache_read_input_tokens // 0))' 2>/dev/null | head -n 1 || echo 0)
    fi
    if [ -z "$TOKENS" ] || [ "$TOKENS" = "0" ]; then
        BYTES=$(stat -c '%s' "$TRANSCRIPT" 2>/dev/null || echo 0)
        TOKENS=$((BYTES / 12))
    fi
    PCT=$((TOKENS * 100 / LIMIT))
    echo "CONTEXT: ~${TOKENS} / ${LIMIT} tokens (${PCT}%)"
    if [ "$PCT" -ge 80 ]; then
        echo "ACTION: >=80% — finish active verification, update HANDOFF.md, prepare clean restart"
    elif [ "$PCT" -ge 70 ]; then
        echo "ACTION: >=70% — refresh HANDOFF.md now (stop-gate threshold)"
    elif [ "$PCT" -ge 60 ]; then
        echo "ACTION: >=60% — delegate all reads/runs/hygiene"
    else
        echo "ACTION: nominal (<60%)"
    fi
fi

H="$REPO/vic/HANDOFF.md"
if [ -f "$H" ]; then
    LINES=$(wc -l < "$H" | tr -d ' ')
    AGE=$(( ($(date +%s) - $(stat -c '%Y' "$H")) / 60 ))
    echo "HANDOFF: $H lines=$LINES age=${AGE}m"
else
    echo "HANDOFF: absent ($H)"
fi
