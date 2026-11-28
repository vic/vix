#!/bin/sh
# ab-compare.sh — Interleaved same-host A/B benchmark runner (POSIX sh, project-agnostic)
# Runs A, B, A, B, ... on identical inputs and reports median retired instructions (if perf available) + wall ms.
# Usage: ab-compare.sh --runs <N> --cmd-a "<cmdA>" --cmd-b "<cmdB>" [--timeout 60]
set -eu

RUNS=3
CMD_A=""
CMD_B=""
TOUT=60

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: ab-compare.sh --cmd-a "<base cmd>" --cmd-b "<cand cmd>" [--runs 3] [--timeout 60]

Runs interleaved A/B pairs (A1, B1, A2, B2, ...) on the same host to cancel thermal/load drift.
Measures retired user instructions via `perf stat --no-inherit -e instructions:u` when available,
plus wall-clock milliseconds, and prints medians + percentage delta.
EOF
            exit 0
            ;;
        --runs) RUNS="$2"; shift 2 ;;
        --cmd-a) CMD_A="$2"; shift 2 ;;
        --cmd-b) CMD_B="$2"; shift 2 ;;
        --timeout) TOUT="$2"; shift 2 ;;
        *) echo "ab-compare: unknown arg: $1" >&2; exit 2 ;;
    esac
done

[ -n "$CMD_A" ] && [ -n "$CMD_B" ] || { echo "ab-compare: --cmd-a and --cmd-b required" >&2; exit 2; }

USE_PERF=0
if command -v perf >/dev/null 2>&1; then
    if perf stat -x, --no-inherit -e instructions:u true >/dev/null 2>&1; then
        USE_PERF=1
    fi
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

run_one() {
    tag="$1"
    cmd="$2"
    t0=$(date +%s%3N 2>/dev/null || printf '%s000' "$(date +%s)")
    if [ "$USE_PERF" -eq 1 ]; then
        perf stat -x, --no-inherit -e instructions:u -o "$TMP/perf.out" -- timeout "$TOUT" sh -c "$cmd" >/dev/null 2>&1
        instr=$(awk -F, '/instructions:u/ { print $1; exit }' "$TMP/perf.out")
    else
        timeout "$TOUT" sh -c "$cmd" >/dev/null 2>&1
        instr="0"
    fi
    t1=$(date +%s%3N 2>/dev/null || printf '%s000' "$(date +%s)")
    wall=$((t1 - t0))
    printf '%s\t%s\n' "${instr:-0}" "$wall" >> "$TMP/$tag.tsv"
}

i=1
while [ "$i" -le "$RUNS" ]; do
    run_one A "$CMD_A"
    run_one B "$CMD_B"
    i=$((i + 1))
done

median_col() {
    file="$1"
    col="$2"
    awk -v c="$col" '{ print $c }' "$file" | sort -n | awk '
        { a[NR] = $1 }
        END {
            if (NR == 0) { print 0; exit }
            mid = int((NR + 1) / 2)
            print a[mid]
        }'
}

AI=$(median_col "$TMP/A.tsv" 1)
BI=$(median_col "$TMP/B.tsv" 1)
AW=$(median_col "$TMP/A.tsv" 2)
BW=$(median_col "$TMP/B.tsv" 2)

awk -v ai="$AI" -v bi="$BI" -v aw="$AW" -v bw="$BW" -v r="$RUNS" -v up="$USE_PERF" '
BEGIN {
    printf "AB-COMPARE (runs=%d interleaved):\n", r
    if (up == 1 && ai > 0) {
        di = ((bi - ai) / ai) * 100.0
        printf "  instructions:u  A=%s  B=%s  delta=%+.3f%%\n", ai, bi, di
    } else {
        printf "  instructions:u  (perf counter unavailable; wall only)\n"
    }
    if (aw > 0) {
        dw = ((bw - aw) / aw) * 100.0
        printf "  wall_ms         A=%s  B=%s  delta=%+.2f%%\n", aw, bw, dw
    } else {
        printf "  wall_ms         A=%s  B=%s\n", aw, bw
    }
}'
