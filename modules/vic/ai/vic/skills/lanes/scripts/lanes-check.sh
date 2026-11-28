#!/bin/sh
# lanes-check.sh — Check lane file lists for pairwise overlaps and max-5 active lane cap (POSIX sh)
# Usage: lanes-check.sh --lane <name:files.txt> --lane <name2:files2.txt> [...] [--max-lanes 5]
set -eu

MAX_LANES=5
LANES=""
COUNT=0

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: lanes-check.sh --lane <name>:<files-list.txt> [--lane <name2>:<files2.txt> ...] [--max-lanes 5]

Verifies:
  1. Active lane count <= --max-lanes (default 5)
  2. Every pair of lanes has strictly disjoint file lists (source AND test files)
Exits 0 on PASS, 1 on overlap or cap breach.
EOF
            exit 0
            ;;
        --max-lanes) MAX_LANES="$2"; shift 2 ;;
        --lane)
            LANES="${LANES}${2}
"
            COUNT=$((COUNT + 1))
            shift 2
            ;;
        *) echo "lanes-check: unknown arg: $1" >&2; exit 2 ;;
    esac
done

[ "$COUNT" -gt 0 ] || { echo "lanes-check: at least one --lane <name>:<file> required" >&2; exit 2; }

FAILS=0
if [ "$COUNT" -gt "$MAX_LANES" ]; then
    echo "FAIL: active lanes ($COUNT) exceeds max ($MAX_LANES)" >&2
    FAILS=$((FAILS + 1))
else
    echo "PASS: active lane count $COUNT <= $MAX_LANES"
fi

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

OLD_IFS="$IFS"
IFS='
'
for spec in $LANES; do
    [ -z "$spec" ] && continue
    lname=$(printf '%s' "$spec" | cut -d: -f1)
    lfile=$(printf '%s' "$spec" | cut -d: -f2-)
    if [ ! -f "$lfile" ]; then
        echo "FAIL: file list missing for lane '$lname': $lfile" >&2
        FAILS=$((FAILS + 1))
        continue
    fi
    awk -v ln="$lname" 'NF > 0 && $0 !~ /^[[:space:]]*#/ { gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print $0 "\t" ln }' "$lfile" >> "$TMP"
done
IFS="$OLD_IFS"

OVERLAPS=$(sort "$TMP" | awk -F'\t' '
    {
        if ($1 in owner && owner[$1] != $2) {
            printf "OVERLAP: %s claimed by both [%s] and [%s]\n", $1, owner[$1], $2
        } else {
            owner[$1] = $2
        }
    }')

if [ -n "$OVERLAPS" ]; then
    printf '%s\n' "$OVERLAPS" >&2
    FAILS=$((FAILS + 1))
else
    echo "PASS: all lane file lists are strictly pairwise disjoint"
fi

[ "$FAILS" -eq 0 ] && { echo "LANES-CHECK: PASS"; exit 0; }
echo "LANES-CHECK: FAIL ($FAILS error(s))" >&2
exit 1
