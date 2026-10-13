#!/usr/bin/env bash
# GLOBAL UserPromptSubmit: context-fill estimate (transcript-size proxy, warns early).
# Silent below threshold = zero token cost. Fail-open.
input=$(cat 2>/dev/null) || exit 0
tp=$(printf '%s' "$input" | sed -n 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$tp" ] && [ -f "$tp" ] || exit 0
bytes=$(stat -c%s "$tp" 2>/dev/null) || exit 0
# /12: transcript jsonl ≈ 3× context chars (metadata+thinking+notifications); live-calibrated after 318% misfire
pct=$((bytes / 12 * 100 / 200000)); [ "$pct" -gt 99 ] && pct=99
if [ "$pct" -ge 60 ]; then
  echo "CTX-METER ~${pct}% (approx). RULE PULSE: code=disposable, law/docs=not · evidence-b4-claim · 1-min rewrite beats hour-fix — re-derive from spec, don't archaeology own context · delegate reads/runs (vic-reader/vic-probe) · >=70%: update <proj>/vic/HANDOFF.md NOW (/handoff), finish minimal, vic does /clear — resume automatic."
fi
exit 0
