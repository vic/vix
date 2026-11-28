#!/bin/sh
# dnet-check.sh — Rust hygiene & crash-path gate for dnet production code (POSIX sh)
# Usage: dnet-check.sh [--repo <dir>] [--src-dir src]
set -eu

REPO="."
SRC_DIR="src"

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: dnet-check.sh [--repo <dir>] [--src-dir src]

Scans non-test Rust source files under <repo>/<src-dir> for forbidden patterns:
  - .unwrap( / .expect( / panic!( / todo!( / unimplemented!(
  - #[allow(warnings)] / #[allow(clippy::all)]
  - #[ignore] on tests (under tests/ and src/)
EOF
            exit 0
            ;;
        --repo) REPO="$2"; shift 2 ;;
        --src-dir) SRC_DIR="$2"; shift 2 ;;
        *) echo "dnet-check: unknown arg: $1" >&2; exit 2 ;;
    esac
done

TARGET="$REPO/$SRC_DIR"
[ -d "$TARGET" ] || { echo "FAIL: source dir not found: $TARGET" >&2; exit 2; }

FAILS=0
fail() { printf 'FAIL: %s\n' "$1" >&2; FAILS=$((FAILS + 1)); }

# Strip inline #[cfg(test)] tails before checking production crash paths
for f in $(find "$TARGET" -type f -name '*.rs' | sort); do
    case "$(basename "$f")" in *test*) continue ;; esac
    HITS=$(awk '
        /#\[cfg\(test\)\]/ { exit }
        /(\.unwrap\(|\.expect\(|(^|[^[:alnum:]_])(panic|todo|unimplemented)!\(|#\[allow\(warnings\)|#\[allow\(clippy::all\))/ {
            if ($0 !~ /^[[:space:]]*\/\//) printf "%s:%d: %s\n", FILENAME, NR, $0
        }
    ' "$f")
    if [ -n "$HITS" ]; then
        fail "forbidden crash/suppression pattern in $f:"
        printf '%s\n' "$HITS" >&2
    fi
done

IGN=$(grep -rn '#\[ignore' "$REPO/$SRC_DIR" "$REPO/tests" 2>/dev/null || true)
if [ -n "$IGN" ]; then
    fail "forbidden #[ignore] test marker found:"
    printf '%s\n' "$IGN" >&2
fi

[ "$FAILS" -eq 0 ] && { echo "DNET-CHECK: PASS ($TARGET)"; exit 0; }
echo "DNET-CHECK: FAIL ($FAILS issue(s))" >&2
exit 1
