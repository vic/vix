#!/bin/sh
# jj-gate.sh — Pre-operation & pre-land Jujutsu health gate (POSIX sh, project-agnostic)
# Usage: jj-gate.sh [--repo <dir>] [--require-clean] [--require-single-ws]
set -eu

REPO="."
REQUIRE_CLEAN=0
REQUIRE_SINGLE_WS=0

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: jj-gate.sh [--repo <dir>] [--require-clean] [--require-single-ws]

Checks:
  1. Valid jj repository (.jj exists)
  2. Zero divergent() commits
  3. Zero conflicts() commits
  4. Optional --require-clean: working copy @ has zero uncommitted changes
  5. Optional --require-single-ws: only default (and optional vic) workspaces remain
EOF
            exit 0
            ;;
        --repo) REPO="$2"; shift 2 ;;
        --require-clean) REQUIRE_CLEAN=1; shift ;;
        --require-single-ws) REQUIRE_SINGLE_WS=1; shift ;;
        *) echo "jj-gate: unknown arg: $1" >&2; exit 2 ;;
    esac
done

FAILS=0
fail() { printf 'FAIL: %s\n' "$1" >&2; FAILS=$((FAILS + 1)); }
pass() { printf 'PASS: %s\n' "$1"; }

if [ ! -d "$REPO/.jj" ]; then
    fail "not a jj repo: $REPO (run 'jj git init --colocate' if git-only)"
    exit 1
fi
pass "jj repo present: $REPO"

DIV=$(jj -R "$REPO" log --no-graph -r 'divergent()' -T 'change_id.short() ++ " " ++ commit_id.short() ++ "\n"' 2>/dev/null || true)
if [ -n "$DIV" ]; then
    fail "divergent() is non-empty:"
    printf '%s\n' "$DIV" >&2
else
    pass "divergent() empty"
fi

CONF=$(jj -R "$REPO" log --no-graph -r 'conflicts()' -T 'change_id.short() ++ " " ++ commit_id.short() ++ "\n"' 2>/dev/null || true)
if [ -n "$CONF" ]; then
    fail "conflicts() is non-empty:"
    printf '%s\n' "$CONF" >&2
else
    pass "conflicts() empty"
fi

if [ "$REQUIRE_CLEAN" -eq 1 ]; then
    DIFF=$(jj -R "$REPO" diff --name-only 2>/dev/null || true)
    if [ -n "$DIFF" ]; then
        fail "working copy @ is dirty (stop-gate triggered):"
        printf '%s\n' "$DIFF" >&2
    else
        pass "working copy @ clean"
    fi
fi

if [ "$REQUIRE_SINGLE_WS" -eq 1 ]; then
    EXTRA=$(jj -R "$REPO" workspace list 2>/dev/null | awk -F: '$1 != "default" && $1 != "vic" { print $1 }' || true)
    if [ -n "$EXTRA" ]; then
        fail "uncleaned secondary workspaces remain: $(printf '%s' "$EXTRA" | tr '\n' ' ')"
    else
        pass "no leftover lane workspaces"
    fi
fi

if [ "$FAILS" -gt 0 ]; then
    printf 'JJ-GATE RESULT: FAIL (%d error(s))\n' "$FAILS" >&2
    exit 1
fi
printf 'JJ-GATE RESULT: PASS\n'
exit 0
