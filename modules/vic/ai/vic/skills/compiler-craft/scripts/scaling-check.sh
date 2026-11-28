#!/bin/sh
# scaling-check.sh — Automated n vs 8n complexity scaling oracle (POSIX sh, project-agnostic)
# For O(n log n), 8n/n is ~8..12x; threshold default 24x cleanly flags O(n^2) (~64x) and O(n^3) (~512x).
# Usage: scaling-check.sh --cmd-1x "<cmd on n>" --cmd-8x "<cmd on 8n>" [--max-ratio 24] [--timeout 60]
set -eu

CMD_1X=""
CMD_8X=""
MAX_RATIO="24.0"
TOUT=60

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: scaling-check.sh --cmd-1x "<cmd on size N>" --cmd-8x "<cmd on size 8N>" [--max-ratio 24.0] [--timeout 60]

Measures retired user instructions (if perf available, else wall ms) on 1x vs 8x input sizes.
Fails (exit 1) if ratio (8x / 1x) exceeds --max-ratio (default 24x, flagging quadratic/cubic blowups).
EOF
            exit 0
            ;;
        --cmd-1x) CMD_1X="$2"; shift 2 ;;
        --cmd-8x) CMD_8X="$2"; shift 2 ;;
        --max-ratio) MAX_RATIO="$2"; shift 2 ;;
        --timeout) TOUT="$2"; shift 2 ;;
        *) echo "scaling-check: unknown arg: $1" >&2; exit 2 ;;
    esac
done

[ -n "$CMD_1X" ] && [ -n "$CMD_8X" ] || { echo "scaling-check: --cmd-1x and --cmd-8x required" >&2; exit 2; }

USE_PERF=0
if command -v perf >/dev/null 2>&1 && perf stat -x, --no-inherit -e instructions:u true >/dev/null 2>&1; then
    USE_PERF=1
fi

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

measure() {
    cmd="$1"
    if [ "$USE_PERF" -eq 1 ]; then
        perf stat -x, --no-inherit -e instructions:u -o "$TMP" -- timeout "$TOUT" sh -c "$cmd" >/dev/null 2>&1
        awk -F, '/instructions:u/ { print $1; exit }' "$TMP"
    else
        t0=$(date +%s%3N 2>/dev/null || printf '%s000' "$(date +%s)")
        timeout "$TOUT" sh -c "$cmd" >/dev/null 2>&1
        t1=$(date +%s%3N 2>/dev/null || printf '%s000' "$(date +%s)")
        echo $((t1 - t0))
    fi
}

V1=$(measure "$CMD_1X")
V8=$(measure "$CMD_8X")
METRIC="wall_ms"
[ "$USE_PERF" -eq 1 ] && METRIC="instructions:u"

awk -v v1="$V1" -v v8="$V8" -v m="$MAX_RATIO" -v met="$METRIC" '
BEGIN {
    if (v1 <= 0) {
        printf "FAIL: 1x measurement <= 0 (%s) — increase base N so counter >> 1\n", v1 > "/dev/stderr"
        exit 1
    }
    ratio = (v8 * 1.0) / (v1 * 1.0)
    verdict = (ratio <= m) ? "PASS" : "FAIL"
    printf "SCALING-CHECK (%s): 1x=%s  8x=%s  ratio=%.2fx (max=%.1fx) -> %s\n", met, v1, v8, ratio, m, verdict
    exit (ratio <= m ? 0 : 1)
}'
