#!/bin/sh
# perf-gate.sh — Deterministic instruction-count & peak-RSS regression gate + atomic TSV logger (POSIX sh)
# Usage:
#   perf-gate.sh --label <L> --base-instr <N> --cand-instr <N> --base-rss <K> --cand-rss <K>
#                [--max-instr-pct 1.0] [--max-rss-pct 2.0]
#                [--wave-base-instr <N> --max-wave-pct 2.0]
#                [--log <perf-log.tsv> --commit <hash> --dep <dep-hash>]
set -eu

usage() {
    cat <<'EOF'
Usage: perf-gate.sh --label <L> --base-instr <N> --cand-instr <N> --base-rss <K> --cand-rss <K> [options]

Options:
  --label <L>            Benchmark label (e.g. parseBenchCandidateT42)
  --base-instr <N>       Baseline retired user instructions (same-host landed main tip)
  --cand-instr <N>       Candidate retired user instructions (median of >=2 runs)
  --base-rss <K>         Baseline peak RSS in KB
  --cand-rss <K>         Candidate peak RSS in KB
  --max-instr-pct <P>    Allowed instruction delta % (default: 1.0)
  --max-rss-pct <P>      Allowed RSS delta % (default: 2.0)
  --wave-base-instr <N>  Optional wave-start instruction baseline (cumulative drift audit)
  --max-wave-pct <P>     Allowed cumulative wave drift % (default: 2.0)
  --log <file.tsv>       Optional perf log TSV to append atomically (temp file + row-count check + mv)
  --commit <hash>        Commit hash for log row (required with --log)
  --dep <hash>           External dependency hash for log row (default: none)
  -h, --help             Show this help
EOF
}

LABEL=""
BASE_I=""
CAND_I=""
BASE_R=""
CAND_R=""
MAX_I="1.0"
MAX_R="2.0"
WAVE_I=""
MAX_W="2.0"
LOG_FILE=""
COMMIT=""
DEP="none"

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        --label) LABEL="$2"; shift 2 ;;
        --base-instr) BASE_I="$2"; shift 2 ;;
        --cand-instr) CAND_I="$2"; shift 2 ;;
        --base-rss) BASE_R="$2"; shift 2 ;;
        --cand-rss) CAND_R="$2"; shift 2 ;;
        --max-instr-pct) MAX_I="$2"; shift 2 ;;
        --max-rss-pct) MAX_R="$2"; shift 2 ;;
        --wave-base-instr) WAVE_I="$2"; shift 2 ;;
        --max-wave-pct) MAX_W="$2"; shift 2 ;;
        --log) LOG_FILE="$2"; shift 2 ;;
        --commit) COMMIT="$2"; shift 2 ;;
        --dep) DEP="$2"; shift 2 ;;
        *) echo "perf-gate: unknown arg: $1" >&2; exit 2 ;;
    esac
done

if [ -z "$LABEL" ] || [ -z "$BASE_I" ] || [ -z "$CAND_I" ] || [ -z "$BASE_R" ] || [ -z "$CAND_R" ]; then
    usage >&2
    exit 2
fi

RESULT=$(awk \
    -v label="$LABEL" \
    -v bi="$BASE_I" -v ci="$CAND_I" -v mi="$MAX_I" \
    -v br="$BASE_R" -v cr="$CAND_R" -v mr="$MAX_R" \
    -v wi="$WAVE_I" -v mw="$MAX_W" '
BEGIN {
    if (bi <= 0 || br <= 0) {
        printf "ERROR: baseline counters must be > 0\n" > "/dev/stderr"
        exit 2
    }
    di = ((ci - bi) / bi) * 100.0
    dr = ((cr - br) / br) * 100.0
    fail = 0
    reasons = ""
    if (di > mi) { fail = 1; reasons = reasons sprintf("instr %+.2f%% > +%.2f%%; ", di, mi) }
    if (dr > mr) { fail = 1; reasons = reasons sprintf("rss %+.2f%% > +%.2f%%; ", dr, mr) }
    wave_str = ""
    if (wi != "" && wi + 0 > 0) {
        dw = ((ci - wi) / wi) * 100.0
        wave_str = sprintf(" wave_instr %+.2f%%", dw)
        if (dw > mw) { fail = 1; reasons = reasons sprintf("wave %+.2f%% > +%.2f%%; ", dw, mw) }
    }
    verdict = fail ? "GATE FAIL" : "GATE PASS"
    printf "%s: instr %s vs %s (%+.2f%%) rss %s vs %s (%+.2f%%)%s -> %s",
           label, ci, bi, di, cr, br, dr, wave_str, verdict
    if (fail) printf " [%s]", reasons
    printf "\n"
    exit fail
}') && STATUS=0 || STATUS=$?

printf '%s\n' "$RESULT"

# Optional atomic append with row-count monotonicity check
if [ -n "$LOG_FILE" ]; then
    if [ -z "$COMMIT" ]; then
        echo "perf-gate: --commit is required with --log" >&2
        exit 2
    fi
    TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    VERDICT="PASS"
    [ "$STATUS" -ne 0 ] && VERDICT="FAIL"
    DIR=$(dirname "$LOG_FILE")
    mkdir -p "$DIR"
    TMP=$(mktemp "$DIR/.perf-log.XXXXXX")
    trap 'rm -f "$TMP"' EXIT
    OLD_ROWS=0
    if [ -f "$LOG_FILE" ]; then
        OLD_ROWS=$(wc -l < "$LOG_FILE" | tr -d ' ')
        cp "$LOG_FILE" "$TMP"
    else
        printf 'timestamp\tcommit\tdep\tlabel\tinstr\trss_kb\tverdict\n' > "$TMP"
        OLD_ROWS=1
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$TS" "$COMMIT" "$DEP" "$LABEL" "$CAND_I" "$CAND_R" "$VERDICT" >> "$TMP"
    NEW_ROWS=$(wc -l < "$TMP" | tr -d ' ')
    if [ "$NEW_ROWS" -le "$OLD_ROWS" ]; then
        echo "perf-gate: atomic log guard tripped (new_rows=$NEW_ROWS <= old_rows=$OLD_ROWS)" >&2
        exit 2
    fi
    mv "$TMP" "$LOG_FILE"
    trap - EXIT
fi

exit "$STATUS"
