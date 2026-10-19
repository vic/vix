#!/usr/bin/env bash
# omni auto-ingest: keep the cross-project knowledge graph fresh.
# Detached + flock-guarded so it NEVER blocks session end and never races itself.
# Incremental (only new transcript lines) => cheap.
LOCK=/tmp/omni-ingest.lock
OMNI=/home/vic/.claude/omni/omni.js
DB=/home/vic/.claude/omni.db
if command -v node >/dev/null 2>&1 && [ -f "$OMNI" ]; then
  ( flock -n 9 || exit 0
    OMNI_DB="$DB" node "$OMNI" ingest >/dev/null 2>&1
  ) 9>"$LOCK" &
fi
exit 0
