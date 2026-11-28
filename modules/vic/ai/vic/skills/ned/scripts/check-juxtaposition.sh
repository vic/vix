#!/bin/sh
# check-juxtaposition.sh — Lint Ned .nix files for forbidden method-chain stream syntax (POSIX sh)
# Usage: check-juxtaposition.sh <file-or-dir>
set -eu

if [ $# -ne 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOF'
Usage: check-juxtaposition.sh <file-or-dir>

Checks Ned .nix files for forbidden stream method-call syntax:
  - <expr>.flatMap / .map / .filter / .fromList (must use juxtaposition: `x (st.flatMap ...)`,
    allowing `st.flatMap` / `ned.st.flatMap` / `lib.map` / `lib.filter` / `builtins.map` / `builtins.filter`)
EOF
    [ $# -eq 1 ] && exit 0 || exit 2
fi

TARGET="$1"
[ -e "$TARGET" ] || { echo "FAIL: path not found: $TARGET" >&2; exit 2; }

FILES=$(find "$TARGET" -type f -name '*.nix' | sort)
FAILS=0

for f in $FILES; do
    HITS=$(awk '
        /^[[:space:]]*#/ { next }
        {
            line = $0
            sub(/#.*/, "", line)
            # Remove legitimate combinator namespace accesses
            gsub(/(ned\.)?st\.(flatMap|map|filter|fromList)/, "OK_ST", line)
            gsub(/(lib|builtins)\.(map|filter)/, "OK_LIB", line)
            if (line ~ /\.(flatMap|map|filter|fromList)([^[:alnum:]_]|$)/) {
                printf "%s:%d: forbidden stream method syntax (use juxtaposition): %s\n", FILENAME, NR, $0
            }
        }
    ' "$f")
    if [ -n "$HITS" ]; then
        printf '%s\n' "$HITS" >&2
        FAILS=$((FAILS + 1))
    fi
done

[ "$FAILS" -eq 0 ] && { echo "NED-JUXTAPOSITION: PASS ($TARGET)"; exit 0; }
echo "NED-JUXTAPOSITION: FAIL ($FAILS file(s) with method-syntax violations)" >&2
exit 1
