---
name: zen
description: Zen Nix module system architecture & implementation law (nix-effects + bend + ned) — 16 hard axioms (zero throw, zero lib.fix over config, effect atoms only, bend lens parsing, ned.run cycle), LoC minimalism budgets, API gotchas (references/api-laws.md), and automated axiom verification (scripts/zen-axioms-check.sh). Use on all Zen design, coding, and review tasks.
---

# ZEN Architecture & Implementation Law (`nix-effects` + `bend` + `ned`)

**Stack:** `/vic` · `/vic-stack` · `/jj` (zero `git`, zero Python) · `/ned` (juxtaposition streams) · `/oracle` (RED tests + armed negative controls before code) · `/probes` (measure eval cost before optimizing).

**Assets in this skill:**
- `references/api-laws.md` — exact verified `bend` lens, merge, `ned.run` eval, `_validateAll`, capability ordering, and dependent-type Nix recipes + 12-phase build order.
- `scripts/zen-axioms-check.sh` — mechanical verifier checking zero `throw`, zero `lib.fix`, zero `.py` files, and LoC budget caps (`kernel.nix <= 550`, total `<= 1500`).

---

## 1. Foundation & 16 Hard Axioms (0 Exception)

Zen = `nix-effects` + `bend` + `ned` (all three required). Types = `bend` lenses (not predicates). Merge = `bend` lens on `[Def]` composed via `bend.pipe`. Config = `ned.run` cycle (NEVER `lib.fix`). Errors = `bend.recordAll` (pure).

1. **No stringly-typed refs** — effect atoms only, no `"/module/path"` strings.
2. **No `throw`** — always `fx.effects.conditions.signal "name" data restarts`.
3. **Blame paths** — every error carries `{ path = [ string ]; file = string; got = value; }`.
4. **Scoped DI** — distinct handler stack per submodule, never global.
5. **No submodule overhead** — `fx.rotate`/`scope-d`, never nested `evalModules`.
6. **NEVER `lib.fix` over config** — `ned.run` cycle only.
7. **Module args ARE effects** — `fx.bind.fn {}`, not `_module.args`.
8. **Observability** — every merge/validate/apply traceable.
9. **Queryable** — modules interrogate environment via effects.
10. **Defaults are effects** — `Computation a`, not static values only.
11. **Apply interceptable** — stream transformer or `zen:apply` effect.
12. **Streams first** — effects over handler stacks or effectful streams.
13. **No infinite recursion guaranteed** — architecture prevents cycles structurally.
14. **Merge is negotiation** — protocol, not an opaque function.
15. **Validation is parsing** — `bend` lenses returning structured errors.
16. **Staged evaluation** — partial configs and deferred resolution.

---

## 2. Critical API Gotchas (full recipes in `references/api-laws.md`)

- `bend.annotate loc` and `bend.ensure pred msg` are **lens modifiers** (wrap the lens; NEVER pass as a `bend.pipe` step).
- `bend.satisfyWith` takes ONE arg (predicate); `bend.map f` / `bend.parse refine` require a second lens arg (`bend.identity`).
- `bend.nonEmpty` changes shape to `{ head; tail }` — never feed it into list functions (`_hp`/`map`).
- `_normDef` MUST preserve `name` (`{ name = def.name; inherit file; } // ...`).
- `_hp []` throws on `head []` -> inject defaults in `_validateAll` BEFORE merge.
- Extract `_uniqueMerge` outside `merges` attrset so `merges.negotiated` never forward-references `merges.unique`.
- Never call `drv` twice outside `ned.run`; capture `result = sources.config` inside `cycle-c`.
- Capability ordering is stream list order — declare capabilities at schema/top level or collect in two passes.

---

## 3. Minimalism Budget & Verification

| Component | Target Max LoC |
|---|---|
| `kernel.nix` | `~510` |
| Tests | `~600` |
| Templates + demo | `~300` |
| **Total** | **`~1410`** (beats both Adios ~985 + Nixpkgs lib 5700+) |

Run `scripts/zen-axioms-check.sh --repo .` + Nix eval/test oracle (with armed failing-input negative controls) before every commit.
