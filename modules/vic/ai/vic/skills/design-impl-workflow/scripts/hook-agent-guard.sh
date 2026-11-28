#!/bin/sh
# hook-agent-guard.sh — Deterministic PreToolUse / shell guardrail hook (POSIX sh, project-agnostic)
# Blocks known agent footguns outside the LLM reasoning loop.
#
# Usage:
#   hook-agent-guard.sh [--worker] --cmd "<command-string>"
#   echo '{"tool_input":{"command":"..."}}' | hook-agent-guard.sh [--worker]
#
# Exit codes:
#   0 = allow
#   2 = deny (reason printed to stderr; compatible with agent PreToolUse hooks)
set -eu

WORKER=0
CMD=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: hook-agent-guard.sh [--worker] [--cmd "<command>"]

Reads command from --cmd or stdin (raw command or JSON containing "command":"...").
Exits 0 to allow, 2 to deny with exact policy rule on stderr.

Enforced rules (all agents):
  - No pkill -f / killall / pgrep -f | xargs kill (kill only by captured $! PID)
  - No sleep-polling loops
  - No pipe-masked exit codes (| ...; echo EXIT=$?)
  - No chained VCS status + mutate (jj st && jj new, git status && git ...)
  - No unguarded direct overwrite of durable logs (> ...perf-log.tsv, > ...state.md)

Extra rules with --worker (coding/mutant/perf subagents):
  - No state-changing VCS commands (jj commit/new/rebase/squash/restore/abandon,
    git commit/push/reset/checkout/rebase/merge/clean)
  - No in-place multi-line perl -i / sed -i / truncate edits
EOF
            exit 0
            ;;
        --worker) WORKER=1; shift ;;
        --cmd) CMD="$2"; shift 2 ;;
        *) echo "hook-agent-guard: unknown arg: $1" >&2; exit 2 ;;
    esac
done

if [ -z "$CMD" ]; then
    RAW=$(cat)
    # Extract "command":"..." if JSON payload, otherwise treat raw stdin as command
    if printf '%s' "$RAW" | grep -q '"command"[[:space:]]*:'; then
        CMD=$(printf '%s' "$RAW" | awk '
            {
                s = s $0 "\n"
            }
            END {
                if (match(s, /"command"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"/)) {
                    m = substr(s, RSTART, RLENGTH)
                    sub(/^"command"[[:space:]]*:[[:space:]]*"/, "", m)
                    sub(/"$/, "", m)
                    gsub(/\\n/, "\n", m)
                    gsub(/\\t/, "\t", m)
                    gsub(/\\"/, "\"", m)
                    gsub(/\\\\/, "\\", m)
                    print m
                }
            }
        ')
    else
        CMD="$RAW"
    fi
fi

deny() {
    printf 'BLOCKED by hook-agent-guard: %s\n' "$1" >&2
    exit 2
}

# 1. Process-killing footguns
if printf '%s' "$CMD" | grep -Eq '(^|[;&|[:space:]])(pkill[[:space:]]+-f|killall[[:space:]]|pgrep[[:space:]]+-f[^;&]*kill)'; then
    deny "forbidden process kill pattern (pkill -f / killall / pgrep -f); kill only by PID captured with \$!"
fi

# 2. Sleep-polling loops
if printf '%s' "$CMD" | grep -Eq '(while|until)[[:space:]].*sleep[[:space:]]+[0-9]'; then
    deny "sleep-polling loop detected; use timeouts or reactive notifications instead"
fi

# 3. Pipe-masked exit codes
if printf '%s' "$CMD" | grep -Eq '\|[^;]*;[[:space:]]*echo[[:space:]]+EXIT=\$\?'; then
    deny "pipe-masked exit code (| ...; echo EXIT=\$?); redirect output to a file, then echo EXIT=\$? immediately after the command"
fi

# 4. Chained VCS status + state-changing command
if printf '%s' "$CMD" | grep -Eq '(jj[[:space:]]+st(atus)?|git[[:space:]]+status)[^|]*&&[[:space:]]*(jj|git)[[:space:]]+(new|commit|rebase|squash|restore|checkout|reset|abandon)'; then
    deny "chained VCS status into mutating VCS command; status is a stop gate — inspect it first"
fi

# 5. Unguarded overwrite of durable logs (allow >> append, block raw > overwrite without temp+mv)
if printf '%s' "$CMD" | grep -Eq '(^|[^>]>[[:space:]]*)([^[:space:]]*(perf-log\.tsv|state\.md|rulings\.md))([[:space:]]|$)'; then
    if ! printf '%s' "$CMD" | grep -Eq '>>[[:space:]]*[^[:space:]]*(perf-log\.tsv|state\.md|rulings\.md)'; then
        deny "unguarded direct overwrite (>) of durable log/ledger; write to a temp file, verify row count && mv atomically"
    fi
fi

# 6. Worker-only restrictions
if [ "$WORKER" -eq 1 ]; then
    if printf '%s' "$CMD" | grep -Eq '(^|[;&|[:space:]])jj[[:space:]]+(commit|ci|new|rebase|squash|restore|abandon|describe|workspace|bookmark|git[[:space:]]+push)'; then
        deny "state-changing jj command is forbidden inside worker subagents (design lead commits and lands)"
    fi
    if printf '%s' "$CMD" | grep -Eq '(^|[;&|[:space:]])git[[:space:]]+(commit|push|reset|checkout|switch|rebase|merge|cherry-pick|clean|stash|worktree)'; then
        deny "state-changing git command is forbidden inside worker subagents (design lead commits and lands)"
    fi
    if printf '%s' "$CMD" | grep -Eq '(^|[;&|[:space:]])(perl[[:space:]]+-0?[pi]|sed[[:space:]]+-i|truncate[[:space:]])'; then
        deny "in-place perl/sed/truncate edit forbidden in worker subagents; use structured Edit/Write tools"
    fi
fi

exit 0
