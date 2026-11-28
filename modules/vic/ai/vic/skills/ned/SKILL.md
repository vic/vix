---
name: ned
description: Ned Cycle.js-inspired Nix stream architecture law — strict juxtaposition syntax (never method chains), ned.run cycle/driver separation, standalone parametric isolation, and edge-only .toList. Use whenever designing, writing, or reviewing Ned Nix streams, cycles, drivers, or Den compat tests.
---

# NED Architecture Law (Cycle.js-inspired Nix Streams)

**Assets in this skill:**
- `references/den-compat.md` — Den fleet-demo compatibility mapping and Nix test runner.
- `scripts/check-juxtaposition.sh` — mechanical linter flagging forbidden stream method-call syntax (`.flatMap`, `.map`, `.filter`, `.fromList`) and non-edge `.toList` calls in `.nix` files.

---

## 1. Core Ontology
- **Everything is a Cycle (`-c`) or a Driver (`-d`); all data moves via Streams (`-s`).**
- `DRIVER`: `Stream -> Stream`
- `CYCLE`: `sources -> sinks` (attrset of streams)
- `STREAM`: `st op op` via **juxtaposition**
- `CTXFN`: `st ({ x }: { ... })` requests `x` from `ctx-d`

## 2. Juxtaposition = Core Rule (ZERO Method Syntax)

- **CORRECT:** `x (st.flatMap fn)` · `infra (st.flatMap fn)` · `st config1 config2`
- **FORBIDDEN (VIOLATION):** `x.flatMap (...)`, `x.map (...)`, `x.filter (...)`, `x.fromList (...)`
- Space between stream and combinator = juxtapose; dot between stream and method = **FORBIDDEN**.
- Use `st { ... }` directly (never `.fromList`); pass all combinators as separate juxtaposed arguments.

## 3. `ned.run` Pattern (Exact Juxtaposition Form)

```nix
# run { infra = infra-d; } outer-c
# 1. outer-c receives sources.infra (host stream)
# 2. Compose strictly via juxtaposition (NEVER .flatMap(...) method chains!):
host-configs = sources.infra (st.flatMap (host: (host-c { inherit host; }).host-config));
user-configs = sources.infra (st.flatMap (host:
  host.users (st.flatMap (user: (user-c { inherit user; }).user-config))
));
```
1. Extract fields directly: `(cycle).field`, never from a raw `.flatMap` method chain.
2. Return `{ infra = st null; inherit host-configs user-configs; }`.
3. Apply collectors (terminal ops on sinks), compose `defaults-s` + collected -> `module-s`.
4. **ONLY `.toList` at the outermost edge** (`module-s.toList` for the NixOS system boundary).

## 4. Isolation & Verification
- **Zero coupling:** cycles are standalone and parametric (no implicit `{ host }` / `{ user }` magic).
- **Streams only:** all data flows `sources -> sinks -> sources` via `st`; collectors aggregate side-effect-free.
- Run `scripts/check-juxtaposition.sh <dir-or-file>` and the Nix oracle (`nix eval` / test suite) before landing.
