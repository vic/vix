#!/bin/sh
# recall-fresh.sh — Check if newest ledger output is fresher than repo working-copy edits (POSIX sh)
# Usage: recall-fresh.sh --repo <dir> [--ledger-dir <dir>]
set -eu

REPO="."
LEDGER_DIR=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: recall-fresh.sh --repo <dir> [--ledger-dir <dir>]

Compares the newest source/working-copy mtime in --repo against the newest bash-*.jsonl
entry in ~/.cache/claude-ledger/ (or --ledger-dir).
Exits 0 if ledger is newer (safe to recall), 1 if repo has newer edits (must re-run).
EOF
            exit 0
            ;;
        --repo) REPO="$2"; shift 2 ;;
        --ledger-dir) LEDGER_DIR="$2"; shift 2 ;;
        *) echo "recall-fresh: unknown arg: $1" >&2; exit 2 ;;
    esac
done

ABS_REPO=$(cd "$REPO" && pwd)
if [ -z "$LEDGER_DIR" ]; then
    KEY=$(printf '%s' "$ABS_REPO" | sed 's|/|_|g')
    if [ -d "$HOME/.cache/claude-ledger/$KEY" ]; then
        LEDGER_DIR="$HOME/.cache/claude-ledger/$KEY"
    else
        LEDGER_DIR="$HOME/.cache/claude-ledger"
    fi
fi

NEWEST_LEDGER=$(find "$LEDGER_DIR" -maxdepth 2 -type f -name 'bash-*.jsonl' -exec stat -c '%Y %n' {} + 2>/dev/null | sort -rn | head -n 1 || true)
if [ -z "$NEWEST_LEDGER" ]; then
    echo "STALE: no bash-*.jsonl ledger found under $LEDGER_DIR (must run command)"
    exit 1
fi
LEDGER_TS=$(printf '%s' "$NEWEST_LEDGER" | awk '{print $1}')
LEDGER_FILE=$(printf '%s' "$NEWEST_LEDGER" | cut -d' ' -f2-)

NEWEST_SRC=$(find "$ABS_REPO" -maxdepth 4 -type f \
    -not -path '*/.jj/*' -not -path '*/.git/*' -not -path '*/build/*' -not -path '*/target/*' -not -path '*/vic/*' \
    -exec stat -c '%Y %n' {} + 2>/dev/null | sort -rn | head -n 1 || true)

if [ -z "$NEWEST_SRC" ]; then
    echo "FRESH: no tracked source files newer than ledger ($LEDGER_FILE)"
    exit 0
fi
SRC_TS=$(printf '%s' "$NEWEST_SRC" | awk '{print $1}')
SRC_FILE=$(printf '%s' "$NEWEST_SRC" | cut -d' ' -f2-)

if [ "$LEDGER_TS" -ge "$SRC_TS" ]; then
    echo "FRESH: ledger ($LEDGER_FILE @ $LEDGER_TS) >= newest source ($SRC_FILE @ $SRC_TS) — safe to vic-recall"
    exit 0
else
    echo "STALE: source ($SRC_FILE @ $SRC_TS) is newer than ledger ($LEDGER_FILE @ $LEDGER_TS) — must re-run"
    exit 1
fi
