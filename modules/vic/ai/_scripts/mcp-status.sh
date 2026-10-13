# Status widget: last MCP tool and the session's MCP call count, e.g. `quipu_search ×7`.
sid=$(jq -r '.session_id // ""')
[[ $sid =~ ^[A-Za-z0-9_-]+$ ]] || exit 0
log="$HOME/.cache/ccstatusline/mcp/$sid"
[[ -s $log ]] || exit 0
last=$(tail -n1 "$log")
last=${last#mcp__}
printf '%s ×%s' "${last#*__}" "$(wc -l <"$log")"
