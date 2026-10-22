#!/usr/bin/env bash
# learn-loop: the PM learning loop without vic present.
# start: point at lessons + open PM beads.
case "${1:-}" in
  start)
    n=$(vic-pm br count --status open 2>/dev/null | tail -1)
    echo "LEARN-LOOP: apply skill vic-lessons (append-only lessons, live in vix repo). Open PM optimization beads: ${n:-0} (vic-pm br ready). End of wave: /vic-retro-loop; verified lessons -> vic-pm learn <vic|pm|skills|traps> \"<lesson>\"."
    ;;
esac
exit 0
