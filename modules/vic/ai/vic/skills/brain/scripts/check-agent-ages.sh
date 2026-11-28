#!/bin/sh
# check-agent-ages.sh — Compute exact subagent transcript ages in seconds (POSIX sh)
# Eliminates human clock-string misreads; flags any agent exceeding --cap-sec (default 600s = 10 min).
# Usage: check-agent-ages.sh --dir <subagents-dir> [--cap-sec 600]
set -eu

DIR=""
CAP=600

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: check-agent-ages.sh --dir <path/to/subagents> [--cap-sec 600]

Computes exact wall age (`now - first_mtime_or_birth` and idle age `now - mtime`) in seconds
for every *.jsonl transcript in --dir. Exits 1 if any active transcript exceeds --cap-sec.
EOF
            exit 0
            ;;
        --dir) DIR="$2"; shift 2 ;;
        --cap-sec) CAP="$2"; shift 2 ;;
        *) echo "check-agent-ages: unknown arg: $1" >&2; exit 2 ;;
    esac
done

[ -n "$DIR" ] && [ -d "$DIR" ] || { echo "FAIL: directory not found: $DIR" >&2; exit 2; }

NOW=$(date +%s)
OVER=0
FOUND=0

for f in "$DIR"/*.jsonl; do
    [ -f "$f" ] || continue
    FOUND=$((FOUND + 1))
    MTIME=$(stat -c '%Y' "$f")
    IDLE=$((NOW - MTIME))
    # Prefer filesystem birth time (%W) if supported (>0), else fallback to mtime
    BTIME=$(stat -c '%W' "$f" 2>/dev/null || echo 0)
    if [ "$BTIME" -gt 0 ] 2>/dev/null; then
        AGE=$((NOW - BTIME))
    else
        AGE="$IDLE"
    fi
    STATUS="OK"
    if [ "$IDLE" -lt 120 ] && [ "$AGE" -gt "$CAP" ]; then
        STATUS="OVER_CAP_STOP"
        OVER=$((OVER + 1))
    elif [ "$IDLE" -ge 120 ]; then
        STATUS="FINISHED_OR_IDLE"
    fi
    printf '%-16s age=%4ds idle=%4ds file=%s\n' "$STATUS" "$AGE" "$IDLE" "$(basename "$f")"
done

if [ "$FOUND" -eq 0 ]; then
    echo "No *.jsonl transcripts in $DIR"
    exit 0
fi

[ "$OVER" -eq 0 ] && exit 0
echo "AGENT-AGE-CHECK: $OVER active agent(s) exceeded ${CAP}s cap -> STOP & SPLIT" >&2
exit 1
