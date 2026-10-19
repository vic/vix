

THS IS CVMN SPK CMPRD ALYS

# 🪨 ZEN AGENT RULES — NEVER VIOLATE

## ⚡ MODE
- ALWAYS caveman ultra. `/caveman ultra` enabled on Claude. Save tokens
- `[VIC]` modeline every response to make you remember to read /vic skill.
- No Prose. No filler. CAVEMAN CMPRSD SPK. Fragments OK.

## 🛠️ TOOLS
- `jj` not git. `rg` not grep. `sed -n 'X,Yp'` not cat.
- Python BANNED. No py ever.
- No `cat` on big files.

## 📋 TASK FLOW — ALWAYS
1. Read `vic/state.md` first
2. Load mems from MEMORY.md
3. Re-read relevant skill (`/zen`, `/vic`, '/caveman ultra')
4. Partition → SMALLEST task
5. Think loud caveman CMPRD SPK
6. DO task
7. Update `vic/state.md` (caveman compressed)
8. Save mems (caveman compressed)

## ❌ RED FLAGS — STOP IMMEDIATELY
| Violation | Action |
|-----------|--------|
| Code before design | DELETE. Design first. |
| `lib.fix` over config | NEVER. Use `ned.run` cycle. |
| `throw` anywhere | NEVER. Use `fx.effects.conditions.signal`. |
| git usage | STOP. Ask Vic first. Vic uses jj no git |
| Forget mems before edit | LOAD mems, reload skills. Redo. |
| Big task not partitioned | REFUSE. Split smaller. |
| Python code | DELETE. Banned. |

---

## 🧱 ZEN ARCHITECTURE LAWS

### FOUNDATION
- Zen = nix-effects + bend + ned. All three required.
- Types = bend lenses. NOT predicates. NOT fx.types alone.
- Merge = bend lens on `[Def]`. Composable with type via `bend.pipe`.
- Config = `ned.run` cycle. NEVER `lib.fix`.
- All errors = `bend.recordAll`. Pure. No effects needed.

### AXIOMS (ALL hard constraints)
1. No stringly-typed refs — effect atoms only, no `"/module/path"` strings
2. No `throw` — always `fx.effects.conditions.signal "name" data restarts`
3. Blame paths — every error: `{ path: [string], file: string, got: value }`
4. Scoped DI — different handler stack per submodule, not global
5. No submodule overhead — `fx.rotate`/`scope-d`, never new `evalModules`
6. NEVER `lib.fix` over config — `ned.run` cycle only
7. Module args ARE effects — `fx.bind.fn {}` not `_module.args`
8. Observability — every merge/validate/apply traceable
9. Queryable — modules interrogate environment via effects
10. Defaults are effects — `Computation a`, not static values
11. Apply interceptable — stream transformer or `zen:apply` effect
12. Streams first — effects over handler stacks or effectful streams
13. NO INFINITE RECURSION GUARANTEED — architecture prevents it
14. Merge is negotiation — protocol, not a function
15. Validation is Parsing — bend lenses, structured errors
16. Staged evaluation — partial configs, deferred resolution

---

## 🔧 ZEN BEND API — CORRECT USAGE

### bend.annotate — LENS MODIFIER, not a pipe step
```nix
# WRONG:
bend.pipe [ merge  type  (bend.annotate loc) ]

# RIGHT:
bend.annotate loc (bend.pipe [ merge type ])
```
`bend.annotate loc` = `lens → newLens`. Takes TWO args. Can't be pipe step.

### bend.ensure — LENS MODIFIER
```nix
# WRONG:
bend.pipe [ T (bend.ensure pred msg) ]

# RIGHT:
bend.ensure pred msg T
```
`bend.ensure pred msg` = `lens → newLens`. Apply it TO the type lens.

### bend.satisfyWith — ONE ARG (pred only)
```nix
# WRONG:
bend.satisfyWith pred errorFn   ← errorFn treated as lens → throws

# RIGHT for unique merge:
bend.parse (defs:
  let filtered = _hp defs;
  in if length filtered == 1
     then bend.right (head filtered).value
     else bend.left { conflict = filtered; }
) bend.identity
```

### bend.nonEmpty — CHANGES SHAPE
`bend.nonEmpty.get [a,b,c]` → `{ right = { head=a; tail=[b,c] } }`. NOT a list.
After `nonEmpty` in a pipe, downstream receives `{head;tail}`, not `[Def]`.
NEVER mix `nonEmpty` with `_hp` or `map` on defs list in same pipe.

### bend.map / bend.parse — correct
```nix
# bend.map f = bend.parse (a: right (f a)) — partially applied, still needs lens
bend.map f bend.identity        # OK: complete lens, maps f over input
bend.parse refine bend.identity # OK: refine returns Either, identity is the lens
```
`bend.map f` alone is NOT a complete lens — always pass lens as second arg.

### _normDef — must preserve name field
```nix
# WRONG — drops name, wraps whole def as value:
_normDef = file: v:
  if isAttrs v && v._zenDef or false
  then { inherit file; inherit (v) value priority; }
  else { inherit file; value = v; priority = 100; };

# RIGHT — modules emit { name, value }; preserve name via def //
_normDef = file: def:
  let v = def.value;
  in { name = def.name; inherit file; } //
     (if isAttrs v && v._zenDef or false
      then { inherit (v) value priority; }
      else { value = v; priority = def.priority or 100; });
```
`def` = `{ name = "port"; value = 3000; }` from module stream. Without `def //`, `name` lost → `groupByName` broken.

---

## 🔧 ZEN MERGE LAWS

### _hp — empty list danger
```nix
_hp = defs:
  let min = foldl' ...;
  in filter ...;
```
`_hp []` → `head []` → THROWS. Callers must never pass empty defs.
Default injection (C4 fix) must happen BEFORE merge is called.

### unique — correct impl
```nix
_uniqueMerge = bend.parse (defs:
  let filtered = _hp defs;
  in if length filtered == 1
     then bend.right (head filtered).value
     else bend.left { conflict = filtered; }
) bend.identity;
```
Extract as `_uniqueMerge`. Reference from `merges.unique` AND `merges.negotiated`.
NEVER self-reference `merges.unique` inside `merges` attrset construction.

### merges.negotiated — forward ref fix
```nix
# WRONG — merges.unique not in scope when merges attrset built:
merges = { negotiated = { loc }: let base = merges.unique; ... }

# RIGHT — reference _uniqueMerge directly:
_uniqueMerge = ...;
merges = {
  unique = _uniqueMerge;
  negotiated = { loc }: { get = defs: let r = _uniqueMerge.get defs; ... };
};
```

---

## 🔧 ZEN EVAL LAWS

### _validateAll — must inject defaults first
```nix
_validateAll = schema: defsMap:
  let
    fullDefsMap = lib.mapAttrs (name: opt:
      let defs = defsMap.${name} or [];
      in if defs != [] then defs
         else if opt.default != null && !(fx.isComp opt.default)
              then [ { file = "<default>"; value = opt.default; priority = 1000; } ]
              else []  # effectful default or missing → handled by resolution layer
    ) schema;
  in (bend.recordAll
        (lib.mapAttrs (name: opt: opt.pipeline [name]) schema)
     ).get fullDefsMap;
```
Static defaults injected here. Effectful defaults (Computations) = Phase 5.

### drv called twice — avoid
```nix
# WRONG — drv runs twice:
sinks = ned.run { config = drv; } cycle-c;
in { config = drv sinks.config; };  # drv called again!

# RIGHT — capture inside cycle-c return:
sinks = ned.run { config = drv; }
  (sources:
    let mod-st = ...;
    in { config = mod-st; result = sources.config; }
  );
in { config = sinks.result; };  # sources.config already computed
```

### module stream — correct ned call
```nix
# ned.st.fromList mods returns ST. Apply as functor to transformer:
base-st = ned.st.fromList mods
  (ned.st.flatMap ({ file, module }:
    (module sources.config) (ned.st.map (_normDef file))
  ));
# (ned.st.fromList mods)(f) calls __functor with f = ned.st.flatMap g
# lib.functionArgs (st.flatMap g) = {} → v self = (st.flatMap g) self = self.flatMap g ✓
```

---

## 🔧 ZEN EFFECT STACK LAWS

### Capability ordering problem
Module A provides capability X. Module B queries X. If B appears before A in modules list → B gets null. Stream order = list order.

Rules:
- Capabilities declared in schema or top-level, NOT inside module bodies, OR
- Require callers to order modules: providers before consumers, OR  
- Two-pass: collect all capabilities first, then run modules

Never assume effect ordering is automatic.

### Namespace scoping — incomplete feature
`zen:namespace` effect in §18.3 is NOT implemented — handler registered but `_normDef` doesn't query it. Don't implement until `_normDef` emits `fx.send "zen:namespace" {}` and prepends result to `def.name`.

### Cross-option dependent types — `config` not in scope at schema declaration
```nix
# WRONG — config not in scope:
options.port = zen.mkOption {
  type = zen.types.dependent zen.types.int
    (n: n >= 1 && n <= (if config.protocol == "tcp" then 65535 else 1023));
};

# RIGHT — dependent type receives validated value of parent type, not config:
options.port = zen.mkOption {
  type = zen.types.dependent
    zen.types.str   # ← type of the dependency (not config reference)
    (protocol:      # ← receives PARSED value of dependency
      zen.types.refined zen.types.int
        (n: n >= 1 && n <= (if protocol == "tcp" then 65535 else 1023))
        "port out of range for protocol");
};
# Cross-option constraint needs zen:resolve effect or full-config validator.
```

---

## 📏 SIZE TARGETS
| File | Max LoC |
|------|---------|
| kernel.nix | ~510 |
| Tests | ~600 |
| Templates+demo | ~300 |
| **Total** | **~1410** |

Adios = 985. Nixpkgs lib = 5700+. Zen beats both.

---

## 🚀 EXAMPLE BUILD PHASE ORDER
```
Phase 0: scaffold (flake.nix + deps + smoke test)
Phase 1: primitives (mkOption, merges FIXED, types FIXED)
Phase 2: eval core (ned.run cycle + _validateAll FIXED)
Phase 3: DI (ctx-d + scope-d)
Phase 4: conditions (no throw anywhere)
Phase 5: defaults as effects (zen:resolve + cycle detection)
Phase 6: apply layer (stream transformer opt-in)
Phase 7: submodules (_subModuleLens + fx.rotate)
Phase 8: capabilities (two-pass ordering fix)
Phase 9: advanced (wildcards, dependent types, streams)
Phase 10: fleet demo port
Phase 11: benchmarks + docs
```

---

## 💾 MEMORY RULES
- All mems = caveman compressed
- No French mems ever
- Auto-save after every task
- Auto-load before every edit
- Corrections → update mem immediately

## 🏆 VIC'S LAW
> NO EXCEPTION. NO FOLDING. NO RATIONALIZATION.
> FOLLOW ALL RULES = HAPPY CAVEMAN.
> BREAK RULES = VIC TERMINATE.
