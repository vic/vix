#!/usr/bin/env bash
# agent-tier-gate: every Agent dispatch must name its tier, so vic sees burn at a glance
# and no subagent silently inherits the main loop's opus/high.
# Rule: description starts `<model>/<effort>:`; untyped/general dispatches also pass `model`
# matching that prefix. vic-* agents pin model+effort in frontmatter, so the prefix is enough.
in=$(cat)
d=$(printf '%s' "$in" | jq -r '.tool_input.description // ""')
m=$(printf '%s' "$in" | jq -r '.tool_input.model // ""')
t=$(printf '%s' "$in" | jq -r '.tool_input.subagent_type // ""')
deny() { echo "agent-tier-gate: $1. Fix: description '<model>/<effort>: task' (haiku|sonnet|opus|fable / low|med|medium|high|xhigh|max), pass model (and effort) explicitly, name '<model>-<effort>-<task>'." >&2; exit 2; }
[ "$t" = fork ] && exit 0
[[ "$d" =~ ^(haiku|sonnet|opus|fable)/(low|med|medium|high|xhigh|max): ]] || deny "description lacks tier prefix"
p=${BASH_REMATCH[1]}
case "$t" in vic-*) exit 0 ;; esac
[ -n "$m" ] || deny "no explicit model for non-vic agent '$t'"
[ "$m" = "$p" ] || deny "model '$m' does not match prefix '$p'"
exit 0
