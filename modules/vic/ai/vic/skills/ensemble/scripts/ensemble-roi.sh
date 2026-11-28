#!/bin/sh
# ensemble-roi.sh — Compare k-shot haiku ensemble cost vs solo higher-tier cost (POSIX sh)
# Usage: ensemble-roi.sh --k <attempts> --rounds <1|2> --haiku-tok <N> --solo-tier sonnet|opus|xhigh --solo-tok <N>
set -eu

K=3
ROUNDS=1
H_TOK=""
S_TIER="sonnet"
S_TOK=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: ensemble-roi.sh --k <attempts> --rounds <1|2> --haiku-tok <tok/attempt> --solo-tier sonnet|opus|xhigh --solo-tok <tok>

Computes weighted relative cost using burn ratios (haiku=1, sonnet=4, opus=8, xhigh=16)
plus judge overhead (~1 haiku unit/round). Exits 0 if ensemble beats solo, 1 if solo is cheaper.
EOF
            exit 0
            ;;
        --k) K="$2"; shift 2 ;;
        --rounds) ROUNDS="$2"; shift 2 ;;
        --haiku-tok) H_TOK="$2"; shift 2 ;;
        --solo-tier) S_TIER="$2"; shift 2 ;;
        --solo-tok) S_TOK="$2"; shift 2 ;;
        *) echo "ensemble-roi: unknown arg: $1" >&2; exit 2 ;;
    esac
done

[ -n "$H_TOK" ] && [ -n "$S_TOK" ] || { echo "ensemble-roi: --haiku-tok and --solo-tok required" >&2; exit 2; }

case "$S_TIER" in
    sonnet) MULT=4 ;;
    opus) MULT=8 ;;
    xhigh|fable) MULT=16 ;;
    *) echo "ensemble-roi: unknown --solo-tier '$S_TIER'" >&2; exit 2 ;;
esac

awk -v k="$K" -v r="$ROUNDS" -v ht="$H_TOK" -v m="$MULT" -v st="$S_TOK" '
BEGIN {
    ens = r * (k + 1) * ht * 1.0
    solo = st * m * 1.0
    ratio = ens / solo
    printf "ENSEMBLE-ROI: ensemble=%.0f haiku-eq-tok (%dx%d+judge) vs solo_%s=%.0f haiku-eq-tok -> ratio=%.2fx ",
           ens, r, k, m, solo, ratio
    if (ens < solo) {
        printf "(ENSEMBLE WINS)\n"
        exit 0
    } else {
        printf "(SOLO WINS — REVERT ROUTING)\n"
        exit 1
    }
}'
