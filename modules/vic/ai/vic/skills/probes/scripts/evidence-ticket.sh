#!/bin/sh
# evidence-ticket.sh — Create, validate, and transition evidence-gate.sh tickets (POSIX sh)
# Usage:
#   evidence-ticket.sh init  --repo <main-repo> [--ws <name>] --measured <hash> --locus "<loc>" --baseline "<nums>"
#   evidence-ticket.sh pass  --repo <main-repo> [--ws <name>] --stub "<res>" --predicted "<delta>" --evidence "ledger:<p>/evidence/<slug>"
#   evidence-ticket.sh fail  --repo <main-repo> [--ws <name>] --stub "<res>" --reason "<why dead>"
#   evidence-ticket.sh check --repo <main-repo> [--ws <name>]
set -eu

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOF'
Usage:
  evidence-ticket.sh init  --repo <main-repo> [--ws default|<lane>] --measured <rev> --locus "<loc>" --baseline "<nums>"
  evidence-ticket.sh pass  --repo <main-repo> [--ws default|<lane>] --stub "<res>" --predicted "<delta>" --evidence "ledger:<proj>/evidence/<slug>"
  evidence-ticket.sh fail  --repo <main-repo> [--ws default|<lane>] --stub "<res>" [--reason "<why>"]
  evidence-ticket.sh check --repo <main-repo> [--ws default|<lane>]

Manages <main-repo>/vic/evidence/<ws>.md in exact compliance with evidence-gate.sh.
EOF
    exit 0
fi

SUB="$1"; shift
REPO="."
WS="default"
MEASURED=""
LOCUS=""
BASELINE=""
STUB=""
PREDICTED=""
EVIDENCE=""
REASON=""

while [ $# -gt 0 ]; do
    case "$1" in
        --repo) REPO="$2"; shift 2 ;;
        --ws) WS="$2"; shift 2 ;;
        --measured) MEASURED="$2"; shift 2 ;;
        --locus) LOCUS="$2"; shift 2 ;;
        --baseline) BASELINE="$2"; shift 2 ;;
        --stub) STUB="$2"; shift 2 ;;
        --predicted) PREDICTED="$2"; shift 2 ;;
        --evidence) EVIDENCE="$2"; shift 2 ;;
        --reason) REASON="$2"; shift 2 ;;
        *) echo "evidence-ticket: unknown arg: $1" >&2; exit 2 ;;
    esac
done

TDIR="$REPO/vic/evidence"
TFILE="$TDIR/${WS}.md"

case "$SUB" in
    init)
        [ -n "$MEASURED" ] && [ -n "$LOCUS" ] && [ -n "$BASELINE" ] || {
            echo "init requires --measured, --locus, --baseline" >&2; exit 2
        }
        mkdir -p "$TDIR"
        cat > "$TFILE" <<EOF
measured: $MEASURED
locus: $LOCUS
baseline: $BASELINE
stub: pending (30-min throwaway ablation window open)
predicted: pending
evidence: pending
verdict: STUB
EOF
        echo "CREATED STUB TICKET (30-min window): $TFILE"
        ;;
    pass)
        [ -f "$TFILE" ] || { echo "FAIL: ticket not found: $TFILE (run init first)" >&2; exit 1; }
        [ -n "$STUB" ] && [ -n "$PREDICTED" ] && [ -n "$EVIDENCE" ] || {
            echo "pass requires --stub, --predicted, --evidence" >&2; exit 2
        }
        printf '%s' "$EVIDENCE" | grep -Eq '^ledger:[a-z0-9-]+/evidence/' || {
            echo "FAIL: --evidence must match ledger:<proj>/evidence/<slug>" >&2; exit 1
        }
        M=$(sed -n 's/^measured:[[:space:]]*//p' "$TFILE" | head -n 1)
        L=$(sed -n 's/^locus:[[:space:]]*//p' "$TFILE" | head -n 1)
        B=$(sed -n 's/^baseline:[[:space:]]*//p' "$TFILE" | head -n 1)
        cat > "$TFILE" <<EOF
measured: $M
locus: $L
baseline: $B
stub: $STUB
predicted: $PREDICTED
evidence: $EVIDENCE
verdict: PASS
EOF
        echo "TRANSITIONED TO PASS: $TFILE"
        ;;
    fail)
        [ -f "$TFILE" ] || { echo "FAIL: ticket not found: $TFILE" >&2; exit 1; }
        M=$(sed -n 's/^measured:[[:space:]]*//p' "$TFILE" | head -n 1)
        L=$(sed -n 's/^locus:[[:space:]]*//p' "$TFILE" | head -n 1)
        B=$(sed -n 's/^baseline:[[:space:]]*//p' "$TFILE" | head -n 1)
        cat > "$TFILE" <<EOF
measured: $M
locus: $L
baseline: $B
stub: ${STUB:-ablation under bar}
predicted: ${REASON:-dead lever — zero production code written}
evidence: none
verdict: FAIL
EOF
        echo "CLOSED AS FAIL (dead lever): $TFILE"
        ;;
    check)
        [ -f "$TFILE" ] || { echo "FAIL: missing ticket $TFILE" >&2; exit 1; }
        V=$(sed -n 's/^verdict:[[:space:]]*//p' "$TFILE" | head -n 1)
        echo "TICKET: $TFILE verdict=${V:-NONE}"
        case "$V" in
            PASS)
                for k in measured locus baseline stub predicted evidence; do
                    grep -Eq "^${k}:[[:space:]]*[^[:space:]]" "$TFILE" || { echo "FAIL: empty field '$k'" >&2; exit 1; }
                done
                grep -Eq '^evidence:[[:space:]]*ledger:[a-z0-9-]+/evidence/' "$TFILE" || { echo "FAIL: invalid evidence label" >&2; exit 1; }
                echo "CHECK: PASS"
                ;;
            STUB)
                AGE=$(( $(date +%s) - $(stat -c %Y "$TFILE") ))
                echo "STUB window age: ${AGE}s / 1800s"
                [ "$AGE" -le 1800 ] || { echo "FAIL: STUB window expired (>30 min)" >&2; exit 1; }
                ;;
            FAIL)
                echo "FAIL: ticket marked FAIL (lever dead)" >&2; exit 1 ;;
            *)
                echo "FAIL: invalid verdict '$V'" >&2; exit 1 ;;
        esac
        ;;
    *)
        echo "evidence-ticket: unknown subcommand '$SUB'" >&2; exit 2 ;;
esac
