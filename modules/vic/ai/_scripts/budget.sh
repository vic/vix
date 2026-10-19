#!/usr/bin/env bash
set -uo pipefail
sub="$HOME/.headroom/subscription_state.json"
event="${1:-unknown}"

payload=""
if [ ! -t 0 ]; then payload="$(cat 2>/dev/null || true)"; fi
transcript=$(printf '%s' "$payload" | jq -r '.transcript_path // empty' 2>/dev/null)

# Orchestrators run 1M-context models. Never take the model from the
# transcript: it drops the [1m] marker and would select a 200K divisor.
limit=1000000
model=$(printf '%s' "$payload" \
  | jq -r 'if (.model|type)=="string" then .model else (.model.id // empty) end' 2>/dev/null)
case "$model" in
  "" | *"[1m]") ;;
  claude-haiku-* | claude-sonnet-*) limit=200000 ;;
esac

ctx="?"
if [ -n "$transcript" ] && [ -s "$transcript" ]; then
  tok=$(jq -r 'select(.type=="assistant") | select(.isSidechain != true)
               | select(.message.usage != null) | .message.usage
               | (.input_tokens//0)+(.cache_read_input_tokens//0)+(.cache_creation_input_tokens//0)' \
          "$transcript" 2>/dev/null | tail -1)
  case "${tok:-}" in
    "" | *[!0-9]*) ;;
    *) ctx=$(awk -v t="$tok" -v l="$limit" 'BEGIN{printf "%.1f", t*100/l}') ;;
  esac
fi

five="?"; seven="?"; mins="?"; stale=""
if [ -s "$sub" ]; then
  vals=$(jq -r '[(.latest.five_hour.utilization_pct // "x"),
                 (.latest.seven_day.utilization_pct // "x"),
                 (.latest.five_hour.seconds_to_reset // 0)] | @tsv' "$sub" 2>/dev/null)
  five=$(printf '%s' "$vals" | cut -f1)
  seven=$(printf '%s' "$vals" | cut -f2)
  secs=$(printf '%s' "$vals" | cut -f3)
  case "$five$seven" in "" | *[!0-9.]*) five="?"; seven="?" ;; esac
  mins=$(awk -v s="${secs:-0}" 'BEGIN{ if (s+0>0) printf "%d", s/60; else printf "?" }')
  age=$(( $(date +%s) - $(stat -c %Y "$sub" 2>/dev/null || echo 0) ))
  [ "$age" -gt 900 ] && stale=" STALE(${age}s)"
fi

gate=""
if [ "$ctx" != "?" ]; then
  gate=$(awk -v c="$ctx" 'BEGIN{
    if (c+0 >= 90)      print "CLOSE OUT (ctx>=90) - the rest of the window is the handoff";
    else if (c+0 >= 75) print "NO FRESH SUBJECTS (ctx>=75) - finish open streams, start nothing new";
  }')
fi
# Weekly outranks context: a session limit resumes cleanly, a weekly one doesn't.
if [ "$seven" != "?" ] && awk -v w="$seven" 'BEGIN{exit !(w+0>=95)}'; then
  gate="CLEAN CLOSEOUT (7d>=95) - unhurried; finish in-flight, no new dispatch"
fi

line=$(printf 'BUDGET %s · ctx %s%% · 5h %s%% (%sm) · 7d %s%%%s%s' \
  "$event" "$ctx" "$five" "$mins" "$seven" "$stale" "${gate:+ · GATE: $gate}")

# Plain stdout reaches the model on SessionStart only; PreToolUse needs JSON.
case "$event" in
  PreToolUse*)
    printf '%s' "$line" \
      | jq -Rs --arg ev "$event" '{hookSpecificOutput:{hookEventName:$ev,additionalContext:.}}'
    ;;
  *) printf '%s\n' "$line" ;;
esac
exit 0
