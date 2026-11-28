#!/usr/bin/env bash
# jj-ws-prune: list, or with --apply forget, empty stalled jj workspaces of the current repo.
# Stalled = empty working copy AND directory missing.
# --include-stale also counts a stale working copy: live agent workspaces look stale until
# updated, so that flag is never a default.
# Never touches `default`, never removes directories: delete a forgotten dir by hand.
set -eu

apply=0
include_stale=0
for arg in "$@"; do
  case "$arg" in
    --apply) apply=1 ;;
    --include-stale) include_stale=1 ;;
    *) echo "usage: jj-ws-prune [--apply] [--include-stale]" >&2; exit 2 ;;
  esac
done

jj workspace list --no-pager | while IFS= read -r line; do
  [[ "$line" =~ ^([^:]+):\ ([^[:space:]]+) ]] || continue
  name="${BASH_REMATCH[1]}"
  path="${BASH_REMATCH[2]}"
  [ "$name" = default ] && continue
  case "$line" in *"(empty)"*) ;; *) continue ;; esac

  if [ ! -d "$path" ]; then
    reason=missing
  elif [ "$include_stale" = 1 ] && jj -R "$path" status --no-pager 2>&1 | grep -q 'stale'; then
    reason=stale
  else
    continue
  fi

  echo "$name $reason $path"
  if [ "$apply" = 1 ]; then
    jj workspace forget "$name"
    echo "forgot $name; dir $path left for manual removal"
  fi
done
