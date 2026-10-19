# PostToolUse(mcp__.*): append the tool name to this session's MCP log.
IFS=$'\t' read -r sid tool < <(jq -r '[.session_id // "", .tool_name // ""] | @tsv')
[[ $sid =~ ^[A-Za-z0-9_-]+$ && $tool == mcp__* ]] || exit 0
dir="$HOME/.cache/ccstatusline/mcp"
mkdir -p "$dir"
printf '%s\n' "$tool" >>"$dir/$sid"
