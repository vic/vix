---
name: gen-build
description: >
  Implements a gate-exited spec in one repository, lands §3a (the gating
  oracle) only, and runs it. Use when the design is settled, the work is
  execution, and the unit is sized to land in one dispatch. Do NOT use it to
  design, to widen scope, or to resolve anything left open — a unit that
  cannot land in one dispatch stops and reports instead.
tools: @TOOLS@
---
