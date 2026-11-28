#!/bin/sh
# bead-close-check.sh — Pre-close evidence verifier for beads / gebed tickets (POSIX sh)
# Usage: bead-close-check.sh --id <bead-id> --title "<read-back title>" --commit <sha> --oracle "<verified line>" [--perf "<gate line>"]
set -eu

ID=""
TITLE=""
COMMIT=""
ORACLE=""
PERF=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: bead-close-check.sh --id <id> --title "<read-back title>" --commit <sha> --oracle "<verified oracle output>" [--perf "<gate line>"]

Verifies all mandatory close-evidence fields before closing a bead or submitting a final gebed_report.
EOF
            exit 0
            ;;
        --id) ID="$2"; shift 2 ;;
        --title) TITLE="$2"; shift 2 ;;
        --commit) COMMIT="$2"; shift 2 ;;
        --oracle) ORACLE="$2"; shift 2 ;;
        --perf) PERF="$2"; shift 2 ;;
        *) echo "bead-close-check: unknown arg: $1" >&2; exit 2 ;;
    esac
done

FAILS=0
fail() { printf 'FAIL: %s\n' "$1" >&2; FAILS=$((FAILS + 1)); }

[ -n "$ID" ] || fail "missing --id"
[ -n "$TITLE" ] || fail "missing --title (read back bead title before closing)"
[ -n "$COMMIT" ] && printf '%s' "$COMMIT" | grep -Eq '^[0-9a-fA-F]{7,40}$' || fail "invalid or missing --commit hex sha: '$COMMIT'"
[ -n "$ORACLE" ] || fail "missing --oracle verified output (never close without evidence)"

if [ "$FAILS" -gt 0 ]; then
    echo "BEAD-CLOSE-CHECK: FAIL ($FAILS error(s))" >&2
    exit 1
fi

printf 'BEAD-CLOSE-CHECK: PASS\n'
printf '  close_reason: commit %s | %s | oracle: %s%s\n' "$COMMIT" "$TITLE" "$ORACLE" "${PERF:+ | perf: $PERF}"
printf '  reminder: submit per-stage gebed_report (measured fields only, omit unknown, never guess 0)\n'
exit 0
