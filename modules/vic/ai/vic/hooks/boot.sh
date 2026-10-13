#!/usr/bin/env bash
# GLOBAL SessionStart: enforce vic workflow boot in EVERY session. Fail-open.
p="${CLAUDE_PROJECT_DIR:-$PWD}"
echo "VIC BOOT (all sessions): invoke Skill vic FIRST — mandatory. Thin-supervisor mode: delegate reads/runs/sweeps to vic-* agents (/dispatch, /lanes); recall-before-run via vic-recall (/ledger); telemetry duty on every dispatch (vic-telemetry add)."
if [ -f "$p/vic/HANDOFF.md" ]; then
  age_h=$(( ($(date +%s) - $(stat -c%Y "$p/vic/HANDOFF.md" 2>/dev/null || date +%s)) / 3600 ))
  echo "RESUME POINT: read $p/vic/HANDOFF.md FIRST (<=25 lines, NEXT-CMD verbatim). AGE: ${age_h}h$([ "$age_h" -gt 48 ] && echo ' — STALE >48h: verify NEXT-CMD vs jj log b4 trusting')."
else
  echo "No $p/vic/HANDOFF.md yet — create vic/ doc structure per /handoff at first task end."
fi
exit 0
