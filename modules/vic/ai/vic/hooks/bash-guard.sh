#!/usr/bin/env bash
# PreToolUse/Bash: refuse shapes the prose law forbids. Exit 2 = block, stderr = feedback.
set -uo pipefail
cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -n "$cmd" ] || exit 0
# command position: line start or after ; & | ( ` $(, past env assignments and sudo/env
at='(^|[;&|(`]|\$\()[[:space:]]*(([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*|sudo|env)[[:space:]]+)*'
refuse() { printf '%s\n' "$1" >&2; exit 2; }

if printf '%s\n' "$cmd" | grep -Eq "${at}pkill[[:space:]]([^;&|]*[[:space:]])?(-[a-zA-Z]*f|--full)"; then
  refuse "Refused: pkill -f matches its own shell and has killed the orchestrator. Kill only a PID captured with \$! at launch."
fi
if printf '%s' "$cmd" | tr '\n' ' ' | grep -Eq '(while|until)[[:space:]].*pgrep[[:space:]]([^;&|]*[[:space:]])?(-[a-zA-Z]*f|--full)'; then
  refuse "Refused: a pgrep -f wait loop matches its own command line and never ends. Wait on a \$! PID (while kill -0 \$pid) or a producer-written marker, under timeout."
fi
if ! printf '%s' "$cmd" | grep -Eq 'timeout[[:space:]]|MemoryMax=' \
  && printf '%s\n' "$cmd" | grep -Eq "${at}nix[[:space:]]+(eval|build|flake[[:space:]]+check)([[:space:]]|\$)"; then
  refuse "Refused: uncapped nix eval/build. Re-run as: timeout 300 $cmd
(or systemd-run --user --scope -q -p MemoryMax=12G $cmd; rc 124/137 is a finding, never re-run uncapped.)"
fi
exit 0
