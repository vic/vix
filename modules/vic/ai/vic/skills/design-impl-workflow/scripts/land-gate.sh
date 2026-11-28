#!/bin/sh
# land-gate.sh — Mechanical pre-land verification gate for a lane workspace (POSIX sh, project-agnostic)
# Usage:
#   land-gate.sh --repo <dir> [--files <allowed-files.txt>] [--manifest <clean.sha256>]
#                [--strict-switch] [--allow-extra <regex>]
set -eu

usage() {
    cat <<'EOF'
Usage: land-gate.sh --repo <dir> [options]

Options:
  --repo <dir>             Lane workspace or repository root (required)
  --files <file>           Newline-separated list of exact relative paths allowed to change
  --manifest <sha256file>  Clean pre-mutant sha256sum manifest to verify restore (relative to --repo)
  --allow-extra <regex>    Optional ERE of extra allowed changed paths (e.g. notes/perf-log)
  --strict-switch          Fail if any changed production file contains a catch-all `default:` arm
  -h, --help               Show this help

Checks:
  1. Clean-restore SHA-256 manifest matches files on disk (catches live mutants!)
  2. VCS status has zero conflicts / divergent commits (supports jj and git)
  3. Changed files strictly subset of --files (+ --allow-extra)
  4. Zero banned production tokens (TODO, FIXME, XXX, abort(, panic(, MUTANT_LIVE, DEBUG_PROBE)
     in changed files (excluding *test* paths for assert/abort helpers where noted)
  5. Optional --strict-switch gate for zero `default:` arms in changed non-test files
EOF
}

REPO=""
FILES_LIST=""
MANIFEST=""
ALLOW_EXTRA=""
STRICT_SWITCH=0

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        --repo) REPO="$2"; shift 2 ;;
        --files) FILES_LIST="$2"; shift 2 ;;
        --manifest) MANIFEST="$2"; shift 2 ;;
        --allow-extra) ALLOW_EXTRA="$2"; shift 2 ;;
        --strict-switch) STRICT_SWITCH=1; shift ;;
        *) echo "land-gate: unknown arg: $1" >&2; exit 2 ;;
    esac
done

if [ -z "$REPO" ] || [ ! -d "$REPO" ]; then
    echo "FAIL: --repo directory required and must exist" >&2
    exit 2
fi

FAILS=0
fail() { printf 'FAIL: %s\n' "$1" >&2; FAILS=$((FAILS + 1)); }
pass() { printf 'PASS: %s\n' "$1"; }

# 1. Clean-restore SHA-256 manifest verification
if [ -n "$MANIFEST" ]; then
    if [ ! -f "$MANIFEST" ]; then
        fail "clean-restore manifest not found: $MANIFEST"
    else
        ABS_MAN=$(cd "$(dirname "$MANIFEST")" && pwd)/$(basename "$MANIFEST")
        if (cd "$REPO" && sha256sum -c "$ABS_MAN" >/dev/null 2>&1); then
            pass "clean-restore SHA-256 manifest matches disk (0 live mutants)"
        else
            fail "clean-restore SHA-256 mismatch (POSSIBLE LIVE MUTANT ON DISK):"
            (cd "$REPO" && sha256sum -c "$ABS_MAN" 2>&1 | grep -v ': OK$' | head -n 10) >&2 || true
        fi
    fi
fi

# 2. Detect VCS & gather changed files + conflict/divergence check
VCS="none"
CHANGED=""
if [ -d "$REPO/.jj" ]; then
    VCS="jj"
    DIV=$(cd "$REPO" && jj log --no-graph -r 'divergent() | conflicts()' -T 'commit_id ++ "\n"' 2>/dev/null || true)
    if [ -n "$DIV" ]; then
        fail "jj reports divergent or conflicted commits: $DIV"
    else
        pass "jj divergent() | conflicts() empty"
    fi
    CHANGED=$(cd "$REPO" && jj diff --name-only 2>/dev/null || true)
elif [ -d "$REPO/.git" ] || [ -f "$REPO/.git" ]; then
    VCS="git"
    CONF=$(cd "$REPO" && git diff --name-only --diff-filter=U 2>/dev/null || true)
    if [ -n "$CONF" ]; then
        fail "git reports unresolved merge conflicts: $CONF"
    else
        pass "git zero unresolved conflicts"
    fi
    CHANGED=$(cd "$REPO" && { git diff --name-only; git diff --cached --name-only; git ls-files --others --exclude-standard; } | sort -u)
else
    fail "neither .jj nor .git found in $REPO"
fi

# 3. Verify changed files match allowed FILES list
if [ -n "$FILES_LIST" ]; then
    if [ ! -f "$FILES_LIST" ]; then
        fail "--files list not found: $FILES_LIST"
    else
        DRIFT=""
        OLD_IFS="$IFS"
        IFS='
'
        for f in $CHANGED; do
            [ -z "$f" ] && continue
            if grep -Fxq -- "$f" "$FILES_LIST"; then
                continue
            fi
            if [ -n "$ALLOW_EXTRA" ] && printf '%s\n' "$f" | grep -Eq "$ALLOW_EXTRA"; then
                continue
            fi
            DRIFT="${DRIFT}${f}
"
        done
        IFS="$OLD_IFS"
        if [ -n "$DRIFT" ]; then
            fail "diff drift outside brief FILES:"
            printf '%s' "$DRIFT" >&2
        else
            pass "changed files strictly within allowed FILES list"
        fi
    fi
fi

# 4. Scan changed production files for banned tokens & mutant residue
BANNED_RE='(TODO|FIXME|XXX|MUTANT_LIVE|DEBUG_PROBE|\babort[[:space:]]*\(|\bpanic[[:space:]]*\()'
OLD_IFS="$IFS"
IFS='
'
for f in $CHANGED; do
    [ -z "$f" ] && continue
    [ ! -f "$REPO/$f" ] && continue
    # Skip docs/markdown/logs for code-token checks
    case "$f" in
        *.md|*.txt|*.tsv|*.json|*.log|*.sha256) continue ;;
    esac
    if grep -En "$BANNED_RE" "$REPO/$f" >/dev/null 2>&1; then
        fail "banned token or residue in $f:"
        grep -En "$BANNED_RE" "$REPO/$f" | head -n 5 >&2
    fi
    if [ "$STRICT_SWITCH" -eq 1 ]; then
        case "$f" in
            *test*|*Test*|*spec*|*Spec*) ;;
            *)
                if grep -En '(^|[^[:alnum:]_])default[[:space:]]*:' "$REPO/$f" >/dev/null 2>&1; then
                    fail "disallowed catch-all default: arm in $f:"
                    grep -En '(^|[^[:alnum:]_])default[[:space:]]*:' "$REPO/$f" | head -n 5 >&2
                fi
                ;;
        esac
    fi
done
IFS="$OLD_IFS"

if [ "$FAILS" -gt 0 ]; then
    printf 'LAND-GATE RESULT: FAIL (%d error(s), vcs=%s)\n' "$FAILS" "$VCS" >&2
    exit 1
fi

printf 'LAND-GATE RESULT: PASS (vcs=%s, repo=%s)\n' "$VCS" "$REPO"
exit 0
