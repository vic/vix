#!/usr/bin/env bash
# SubagentStart: inject the worker contract into every subagent (reaches the SUBAGENT's context).
set -uo pipefail
d="$HOME/.cache/claude-ledger/$(printf "%s" "${CLAUDE_PROJECT_DIR:-$PWD}" | sed "s|/|-|g")"; mkdir -p "$d"; date +%s >> "$d/sub-starts" 2>/dev/null
c='WORKER CONTRACT: max 3 fix attempts (1 attempt = one change + one check run); after the 3rd failure STOP, report blocked, no 4th try. Never widen scope to make a check pass. End EVERY run with this block:
REPORT
status: done | partial | blocked | specgap
capable: yes | no · <why: missing info, tool, access, skill, or task too big for one run>
attempts: <n>/3
class: recon | impl | debug | design | review | doc | measure | law
evidence: <cmd + decisive output line, or file path>
blocker: <precise blocker, or ->
metrics: secs=<n> tool_calls=<n> files_touched=<n>

BEFORE work: quipu_context / quipu_search_facts on the task entities; use what is recorded. Read skill vic-lessons traps.md. Never pkill -f, killall, or kill on pgrep -f output; kill only a PID captured with $!. Write big output to files and return the paths, not the content.'
jq -nc --arg c "$c" '{hookSpecificOutput: {hookEventName: "SubagentStart", additionalContext: $c}}'
