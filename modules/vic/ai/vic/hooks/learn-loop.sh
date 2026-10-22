#!/usr/bin/env bash
# learn-loop: the PM learning loop without vic present.
# start: rebuild the local ledger from the repo (new machine self-heals), point at lessons + open PM beads.
# stop:  copy ledgers into the repo so telemetry survives a hardware move.
case "${1:-}" in
  start)
    vic-pm restore >/dev/null 2>&1
    n=$(vic-pm br count --status open 2>/dev/null | tail -1)
    echo "LEARN-LOOP: apply skill vic-lessons (append-only lessons, live in vix repo). Open PM optimization beads: ${n:-0} (vic-pm br ready). End of wave: /vic-retro-loop; verified lessons -> vic-pm learn <vic|pm|skills|traps> \"<lesson>\"."
    ;;
  stop) vic-pm sync >/dev/null 2>&1 ;;
esac
exit 0
