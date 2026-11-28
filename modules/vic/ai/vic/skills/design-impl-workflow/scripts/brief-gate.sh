#!/bin/sh
# brief-gate.sh — Mechanical pre-dispatch verifier for task briefs (POSIX sh, project-agnostic)
# Usage: brief-gate.sh <brief-file> [--type task|probe|land-verify] [--repo <repo-dir>]
set -eu

usage() {
    cat <<'EOF'
Usage: brief-gate.sh <brief-file> [--type task|probe|land-verify] [--repo <repo-dir>]

Checks a staged brief before dispatch:
  - Zero unfilled <PLACEHOLDER> tokens
  - Required sections present for brief type
  - Ticket/bead line has plain ID (no tracker CLI flags)
  - 10-minute cap stated
  - No owner/user authority quotes to implementer
  - No external Skill tool invocation required inside worker prompts
  - No pipe-masked exit codes (| ...; echo EXIT=$?)
  - No line-number edit instructions ("lines 12-40", "at line 55")
  - No multi-line perl -i / sed -i edit instructions
  - No sentinel value prescriptions (UINT64_MAX / -1 sentinel)
  - Optional (--repo): verifies mutant `before:` anchors match exactly once
EOF
}

if [ $# -lt 1 ]; then
    usage >&2
    exit 2
fi

BRIEF=""
TYPE="task"
REPO=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        --type) TYPE="$2"; shift 2 ;;
        --repo) REPO="$2"; shift 2 ;;
        -*) echo "brief-gate: unknown option: $1" >&2; exit 2 ;;
        *)
            if [ -z "$BRIEF" ]; then
                BRIEF="$1"
            else
                echo "brief-gate: unexpected argument: $1" >&2
                exit 2
            fi
            shift
            ;;
    esac
done

if [ ! -f "$BRIEF" ]; then
    echo "FAIL: brief file not found: $BRIEF" >&2
    exit 1
fi

FAILS=0
fail() {
    printf 'FAIL: %s\n' "$1" >&2
    FAILS=$((FAILS + 1))
}

pass() {
    printf 'PASS: %s\n' "$1"
}

# 1. Unfilled placeholders like <ID>, <BASELINES>, <TASK_NAME>
if grep -En '<[A-Z][A-Z0-9_-]+>' "$BRIEF" >/dev/null 2>&1; then
    fail "unfilled placeholder(s) found:"
    grep -En '<[A-Z][A-Z0-9_-]+>' "$BRIEF" | head -n 10 >&2
else
    pass "no unfilled <PLACEHOLDER> tokens"
fi

# 2. Required sections by brief type
check_section() {
    pat="$1"
    label="$2"
    if grep -Eq "$pat" "$BRIEF"; then
        pass "section present: $label"
    else
        fail "missing required section: $label"
    fi
}

check_section '^TASK ' "TASK header"
check_section '^AGENTS' "AGENTS"
check_section '^COMMANDS' "COMMANDS"
check_section '^REPORT' "REPORT"

if [ "$TYPE" = "task" ]; then
    check_section '^(BEAD|TICKET):' "BEAD/TICKET line"
    check_section '^GOAL LINE:' "GOAL LINE"
    check_section '^WHY:' "WHY (spec + ruling citations)"
    check_section '^FILES' "FILES list"
    check_section '^CONTRACT:' "CONTRACT"
    check_section '^STEPS:' "STEPS"
    check_section '^MUTANTS' "MUTANTS"
    check_section '^EXPECT:' "EXPECT"
    check_section '^PERF' "PERF section"
    check_section '^FAILURE-PATTERN' "FAILURE-PATTERN BOX"
fi

# 3. 10-minute cap
if grep -Eiq '(10[- ]min|10 minute)' "$BRIEF"; then
    pass "10-minute cap present"
else
    fail "missing 10-minute cap"
fi

# 4. Ticket/bead line must not contain tracker CLI hints or flags
if grep -E '^(BEAD|TICKET):.*(--db|--repo|--token|br |bd |gh issue|jira |linear )' "$BRIEF" >/dev/null 2>&1; then
    fail "BEAD/TICKET line contains tracker CLI tool hints (keep plain ID only)"
else
    pass "BEAD/TICKET line free of CLI tool hints"
fi

# 5. Never mention/quote owner or user authority to implementer
if grep -Eiq '\b(the user said|the owner said|owner ordered|user ordered|per the user|per the owner)\b' "$BRIEF"; then
    fail "brief quotes owner/user authority to implementer (use role + written law file only)"
else
    pass "no owner/user authority quotes"
fi

# 6. Never tell worker subagents to invoke external Skill tools
if grep -Eiq '(invoke skill|call skill tool|use the skill tool)' "$BRIEF"; then
    fail "brief asks worker subagent to invoke external Skill tool (inline core laws + law file path instead)"
else
    pass "no external Skill tool requirement in worker instructions"
fi

# 7. Pipe-masked exit codes: `| ...; echo EXIT=$?`
if grep -En '\|[^;]*;[[:space:]]*echo[[:space:]]+EXIT=\$\?' "$BRIEF" >/dev/null 2>&1; then
    fail "pipe-masked exit code detected (capture to file, then echo EXIT=\$? right after command):"
    grep -En '\|[^;]*;[[:space:]]*echo[[:space:]]+EXIT=\$\?' "$BRIEF" | head -n 5 >&2
else
    pass "no pipe-masked EXIT=\$? commands"
fi

# 8. Line-number edit prescriptions (anchor edits by exact text, never line numbers)
if grep -Eni '\b(edit|replace|change|insert|delete)[[:space:]]+(at[[:space:]]+)?lines?[[:space:]]+[0-9]+([[:space:]]*-[[:space:]]*[0-9]+)?' "$BRIEF" >/dev/null 2>&1; then
    fail "line-number edit instruction detected (anchor edits by exact text instead):"
    grep -Eni '\b(edit|replace|change|insert|delete)[[:space:]]+(at[[:space:]]+)?lines?[[:space:]]+[0-9]+([[:space:]]*-[[:space:]]*[0-9]+)?' "$BRIEF" | head -n 5 >&2
else
    pass "no line-number edit prescriptions"
fi

# 9. Multi-line perl -i / sed -i edit instructions
if grep -En '\b(perl[[:space:]]+-0?[pi]|sed[[:space:]]+-i)' "$BRIEF" >/dev/null 2>&1; then
    fail "in-place perl/sed edit instruction detected (use structured Edit/Write tools):"
    grep -En '\b(perl[[:space:]]+-0?[pi]|sed[[:space:]]+-i)' "$BRIEF" | head -n 5 >&2
else
    pass "no in-place perl/sed edit instructions"
fi

# 10. Sentinel value prescription warning
if grep -Eni '(UINT64_MAX|SIZE_MAX|INT_MAX|-1)[[:space:]]+(as[[:space:]]+)?(a[[:space:]]+)?sentinel' "$BRIEF" >/dev/null 2>&1; then
    fail "brief prescribes an overloaded sentinel value (use a closed typed outcome instead)"
else
    pass "no overloaded sentinel prescription"
fi

# 11. Optional mutant anchor verification against --repo
# Expects lines of the form: `  - m1 (<relpath>, ...)` followed by `before: \`...\``
if [ -n "$REPO" ]; then
    if [ ! -d "$REPO" ]; then
        fail "--repo directory does not exist: $REPO"
    else
        ANCHOR_ERRS=$(awk -v repo="$REPO" '
            /^[[:space:]]*-[[:space:]]*m[0-9]+[[:space:]]*\(/ {
                cur_file = ""
                if (match($0, /\([^,)]+/)) {
                    cur_file = substr($0, RSTART + 1, RLENGTH - 1)
                    gsub(/^[[:space:]]+|[[:space:]]+$/, "", cur_file)
                }
                predicted = (tolower($0) ~ /predicted/)
                next
            }
            cur_file != "" && /before:[[:space:]]*`/ {
                if (predicted) { cur_file = ""; next }
                line = $0
                sub(/^.*before:[[:space:]]*`/, "", line)
                sub(/`.*$/, "", line)
                if (line != "") {
                    printf "%s\t%s\n", cur_file, line
                }
                cur_file = ""
            }
        ' "$BRIEF")

        if [ -n "$ANCHOR_ERRS" ]; then
            OLD_IFS="$IFS"
            IFS='
'
            for entry in $ANCHOR_ERRS; do
                rel=$(printf '%s' "$entry" | cut -f1)
                needle=$(printf '%s' "$entry" | cut -f2-)
                target="$REPO/$rel"
                if [ ! -f "$target" ]; then
                    fail "mutant anchor target missing: $rel"
                else
                    cnt=$(grep -Fc -- "$needle" "$target" 2>/dev/null || true)
                    if [ "$cnt" -ne 1 ]; then
                        fail "mutant anchor in $rel matched $cnt times (must be 1): $needle"
                    else
                        pass "mutant anchor unique (1 match) in $rel"
                    fi
                fi
            done
            IFS="$OLD_IFS"
        fi
    fi
fi

if [ "$FAILS" -gt 0 ]; then
    printf 'BRIEF-GATE RESULT: FAIL (%d error(s))\n' "$FAILS" >&2
    exit 1
fi

printf 'BRIEF-GATE RESULT: PASS (%s)\n' "$BRIEF"
exit 0
