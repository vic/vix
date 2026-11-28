#!/usr/bin/env bash
# dev-principle: states the evidence rule before every edit. Context only, never blocks;
# evidence-gate.sh is the enforcement.
jq -nc '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: "All development is gated by evidence. Identify risks. Measure with experiments. Obtain data. Prioritize tasks that deliver more outcome for less effort. No coding for hours while obtaining small returns."}}'
