#!/usr/bin/env bash
printf '%s\tstopped\n' "$(date -Is)" >> "$HOME/.claude/subagent-stops.log" 2>/dev/null
cat <<'MSG'
A subagent just STOPPED.

If its report has NOT arrived: TREE FIRST, then prompt ONCE. Never re-dispatch — a
resend duplicates completed work, while a message revives the agent with its context.
Read the artefact it was told to write before assuming nothing happened.

A silent idle is NOT a clean result. Never infer a finding, a pass, or an absence from
a report that never arrived — say it is outstanding.
MSG
exit 0
