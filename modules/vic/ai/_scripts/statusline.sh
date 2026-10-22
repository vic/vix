#!/usr/bin/env bash
# One status line: model+effort · ctx% · 5h/7d quota · $ · tokens · PM beads · agents. <=110 cols, <100ms.
set -uo pipefail
in=$(cat)
IFS='|' read -r model eff cwd tr cost < <(printf '%s' "$in" | jq -r '[
  (.model.display_name // .model.id // "?"), ((.effort | if type=="object" then .level else . end) // ""),
  (.workspace.current_dir // .cwd // ""), (.transcript_path // ""),
  (.cost.total_cost_usd // "")] | join("|")' 2>/dev/null)
cwd=${cwd:-$PWD}

# ctx from the last main-thread usage row (1M window, as in _scripts/budget.sh); tail keeps it fast
limit=1000000; ctx="?"; tok=""
if [ -n "$tr" ] && [ -s "$tr" ]; then
  tok=$(tail -n 60 "$tr" | jq -r 'select(.type=="assistant") | select(.isSidechain != true)
    | select(.message.usage != null) | .message.usage
    | (.input_tokens//0)+(.cache_read_input_tokens//0)+(.cache_creation_input_tokens//0)' 2>/dev/null | tail -1)
  case "${tok:-}" in "" | *[!0-9]*) ;; *) ctx=$(( tok * 100 / limit )) ;; esac
fi

# quota from headroom, same source as budget.sh
five="?"; seven="?"; r5=0; r7=0
sub="$HOME/.headroom/subscription_state.json"
if [ -s "$sub" ]; then
  # remaining = resets_at - now: seconds_to_reset in the file is frozen at polled_at
  IFS=$'\t' read -r five seven r5 r7 < <(jq -r --argjson now "$(date +%s)" '.latest | [
    (.five_hour.utilization_pct // "?"), (.seven_day.utilization_pct // "?"),
    ((.five_hour.resets_at // empty | fromdateiso8601) - $now), ((.seven_day.resets_at // empty | fromdateiso8601) - $now)]
    | map(if type=="number" then floor else . end) | @tsv' "$sub" 2>/dev/null)
fi
# "<reset in> <burn>/unit <hot>": burn = pct used per elapsed window time; hot=1 when it projects past 100% at reset
burn() { # pct remaining_s window_s unit_s unit_name
  awk -v p="$1" -v r="$2" -v w="$3" -v u="$4" -v n="$5" 'BEGIN{
    if (p !~ /^[0-9]+$/ || r < 0 || r > w) { print "?"; exit }
    e = w - r
    t = r >= 86400 ? sprintf("%dd%dh", r/86400, (r%86400)/3600) : r >= 3600 ? sprintf("%dh%02dm", r/3600, (r%3600)/60) : sprintf("%dm", r/60)
    if (e < 60) { print t; exit }
    b = p * u / e; printf "%s %.1f%%/%s %d", t, b, n, (p + b * r / u >= 100)
  }'
}
b5=$(burn "$five" "${r5:-0}" 18000 3600 h); b7=$(burn "$seven" "${r7:-0}" 604800 86400 d)

# when the 7d quota hits 100% at the burn rate so far: epoch seconds from now, or "-" when it lasts past the reset
dry=$(awk -v p="$seven" -v r="${r7:-0}" -v w=604800 'BEGIN{
    e = w - r
    if (p !~ /^[0-9]+$/ || r < 0 || r > w || e < 60 || p <= 0) { print "-"; exit }
    s = (100 - p) * e / p
    print (s >= r) ? "-" : int(s)
  }')

# open pm beads, cached 60s: br is the slow part
cache="${XDG_RUNTIME_DIR:-/tmp}/statusline-pm-open"
if [ ! -f "$cache" ] || [ $(( $(date +%s) - $(stat -c %Y "$cache") )) -gt 60 ]; then
  { "${VIC_PM:-$HOME/hk/vix/modules/vic/ai/vic/bin/vic-pm}" br count --status open 2>/dev/null || echo "?"; } | grep -oE '[0-9]+|\?' | head -1 > "$cache.$$"
  mv "$cache.$$" "$cache"
fi
pm=$(cat "$cache" 2>/dev/null); pm=${pm:-?}

# agents: in flight = starts (subagent-brief.sh) minus stops (subagent-stop.sh) in the last hour; last stop = tier/status
d="$HOME/.cache/claude-ledger/${cwd//\//-}"
now=$(date +%s); ag=0; last=""
if [ -f "$d/sub-starts" ]; then
  s=$(awk -v t=$((now-3600)) '$1>t' "$d/sub-starts" | wc -l)
  e=$(tail -n 50 "$d/subagents.tsv" 2>/dev/null | awk -F'\t' -v t="$(date -d @$((now-3600)) -Is)" '$1>t' | wc -l)
  ag=$(( s > e ? s - e : 0 ))
fi
[ -f "$d/subagents.tsv" ] && last=$(tail -n1 "$d/subagents.tsv" | awk -F'\t' '{sub(/^vic-/,"",$2); printf "%s:%s", $2, $7}')

c() { printf '\033[%sm%s\033[0m' "$1" "$2"; }
cc=32; case "$ctx" in "?") cc=90 ;; *) if [ "$ctx" -ge 85 ]; then cc=31; elif [ "$ctx" -ge 70 ]; then cc=33; fi ;; esac
sc=35; case "$seven" in "?") sc=90 ;; *) [ "$seven" -ge 90 ] && sc=31 ;; esac

# trailing 0/1 from burn(): red when projected to exhaust before reset
q() { case "$1" in *" 1") c 31 "${1% 1}" ;; *" 0") printf '%s' "${1% 0}" ;; *) printf '%s' "$1" ;; esac; }
o="$(c 36 "$model")${eff:+ $(c 90 "$eff")} · ctx $(c $cc "$ctx%") · 5h $(c 34 "$five%") $(q "$b5") · 7d $(c $sc "$seven%") $(q "$b7")"
[ "$dry" != "-" ] && o+=" $(c 31 "dry $(date -d "+${dry} seconds" +"%a %H:%M")")"
[ -n "$cost" ] && o+=" · $(c 93 "\$$(printf '%.2f' "$cost")")"
[ -n "$tok" ] && o+=" $(c 34 "$(( tok / 1000 ))k")"
o+=" · PM $(c 36 "$pm")"
o+=" · ag $ag${last:+ $(c 90 "$last")}"
printf '%s\n' "$o"
