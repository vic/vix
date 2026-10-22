#!/usr/bin/env bash
in=$(cat)

# Deterministic telemetry: one quipu row per subagent stop (global graph, group_id telemetry),
# so PM learning does not depend on PM remembering `vic-telemetry add`. Missing fields log as "-".
{
  t=$(printf '%s' "$in" | jq -r '.agent_transcript_path // empty' 2>/dev/null)
  tok=- secs=-
  if [ -n "$t" ] && [ -f "$t" ]; then
    tok=$(jq -s '[.[].message.usage.output_tokens // 0] | add' "$t" 2>/dev/null || echo -)
    secs=$(jq -rs '[.[].timestamp // empty | sub("\\.[0-9]+";"") | fromdateiso8601] | if length>1 then (max-min) else "-" end' "$t" 2>/dev/null || echo -)
  fi
  msg=$(printf '%s' "$in" | jq -r '.last_assistant_message // ""')
  st=$(printf '%s' "$msg" | sed -n 's/^status: *\([a-z]*\).*/\1/p' | tail -1)
  at=$(printf '%s' "$msg" | sed -n 's/^attempts: *\([0-9]*\).*/\1/p' | tail -1)
  vic-telemetry subagent "$(printf '%s' "$in" | jq -r '.agent_type // "-"')" \
    "$(printf '%s' "$in" | jq -r '.agent_id // "-"')" "$(printf '%s' "$in" | jq -r '.effort // "-"')" \
    "$tok" "$secs" "${st:--}" "${at:--}"
} 2>/dev/null

# WORKER CONTRACT (skill vic-lessons): no REPORT block = send the agent back once to write it.
if ! printf '%s' "$in" | jq -r '.last_assistant_message // ""' | grep -q '^REPORT' \
  && [ "$(printf '%s' "$in" | jq -r '.stop_hook_active // false')" != true ]; then
  jq -n '{decision:"block",reason:"End with the REPORT block (skill vic-lessons, WORKER CONTRACT): REPORT / status / capable / attempts / class / evidence / blocker / metrics. Do not do more work; only report."}'
  exit 0
fi

cat <<'MSG'
A subagent just STOPPED.

If its report has NOT arrived: TREE FIRST, then prompt ONCE. Never re-dispatch — a
resend duplicates completed work, while a message revives the agent with its context.
Read the artefact it was told to write before assuming nothing happened.

A silent idle is NOT a clean result. Never infer a finding, a pass, or an absence from
a report that never arrived — say it is outstanding.
MSG
exit 0
