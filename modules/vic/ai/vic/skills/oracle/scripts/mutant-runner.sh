#!/bin/sh
# mutant-runner.sh — Clean-restore SHA-256 verified single-mutant executor (POSIX sh, project-agnostic)
# Usage:
#   mutant-runner.sh --file <path> --before "<exact text>" --after "<mutated text>"
#                    --cmd "<build && test cmd>" [--expect-build-fail] [--timeout 120]
set -eu

FILE=""
BEFORE=""
AFTER=""
CMD=""
EXPECT_BUILD_FAIL=0
TOUT=120

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: mutant-runner.sh --file <path> --before "<exact text>" --after "<mutated text>" --cmd "<test cmd>" [--expect-build-fail] [--timeout 120]

Safety guarantees:
  1. Verifies `--before` matches EXACTLY ONCE in --file (prevents silent no-op mutants)
  2. Saves clean snapshot + records clean SHA-256
  3. Always restores clean snapshot via EXIT trap, then proves byte-identical cmp + sha256sum
  4. Exits 0 iff mutant KILLED (cmd returned non-zero) AND clean restore verified byte-identical
  5. Exits 1 if mutant SURVIVED (cmd returned 0) or anchor/restore check failed
EOF
            exit 0
            ;;
        --file) FILE="$2"; shift 2 ;;
        --before) BEFORE="$2"; shift 2 ;;
        --after) AFTER="$2"; shift 2 ;;
        --cmd) CMD="$2"; shift 2 ;;
        --expect-build-fail) EXPECT_BUILD_FAIL=1; shift ;;
        --timeout) TOUT="$2"; shift 2 ;;
        *) echo "mutant-runner: unknown arg: $1" >&2; exit 2 ;;
    esac
done

[ -n "$FILE" ] && [ -f "$FILE" ] || { echo "FAIL: --file missing or not found: $FILE" >&2; exit 2; }
[ -n "$BEFORE" ] && [ -n "$AFTER" ] && [ -n "$CMD" ] || { echo "FAIL: --before, --after, --cmd required" >&2; exit 2; }

CNT=$(grep -Fc -- "$BEFORE" "$FILE" 2>/dev/null || true)
if [ "$CNT" -ne 1 ]; then
    echo "FAIL: anchor in $FILE matched $CNT times (must be 1): $BEFORE" >&2
    exit 1
fi

TMP=$(mktemp -d)
SNAP="$TMP/clean.snap"
cp "$FILE" "$SNAP"
CLEAN_SHA=$(sha256sum "$SNAP" | awk '{print $1}')

restore() {
    cp "$SNAP" "$FILE"
    rm -rf "$TMP"
}
trap restore EXIT

# Apply exact single literal replacement via awk (POSIX-safe, no regex metacharacter hazards)
awk -v b="$BEFORE" -v a="$AFTER" '
BEGIN { done = 0 }
{
    if (!done) {
        idx = index($0, b)
        if (idx > 0) {
            $0 = substr($0, 1, idx - 1) a substr($0, idx + length(b))
            done = 1
        }
    }
    print
}
END { if (!done) exit 3 }
' "$SNAP" > "$FILE"

MUT_SHA=$(sha256sum "$FILE" | awk '{print $1}')
if [ "$MUT_SHA" = "$CLEAN_SHA" ]; then
    echo "FAIL: mutant produced identical file hash (no-op edit)" >&2
    exit 1
fi

OUT="$TMP/run.out"
if timeout "$TOUT" sh -c "$CMD" >"$OUT" 2>&1; then
    RC=0
else
    RC=$?
fi

# Explicit restore + byte-identical verification before reporting
cp "$SNAP" "$FILE"
REST_SHA=$(sha256sum "$FILE" | awk '{print $1}')
cmp -s "$SNAP" "$FILE" || { echo "CRITICAL FAIL: clean restore cmp mismatch on $FILE" >&2; exit 2; }
[ "$REST_SHA" = "$CLEAN_SHA" ] || { echo "CRITICAL FAIL: clean restore sha mismatch on $FILE" >&2; exit 2; }
trap - EXIT
rm -rf "$TMP"

if [ "$RC" -eq 0 ]; then
    echo "MUTANT SURVIVED (TEST GAP or DEAD CODE): file=$FILE rc=0 restore_sha=$REST_SHA (MATCH)" >&2
    exit 1
fi

KIND="KILLED"
[ "$EXPECT_BUILD_FAIL" -eq 1 ] && KIND="KILLED (compile-fail)"
echo "MUTANT $KIND: file=$FILE rc=$RC restore_sha=$REST_SHA (MATCH)"
exit 0
