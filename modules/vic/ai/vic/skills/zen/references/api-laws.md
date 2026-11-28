# Zen Verified API Recipes & Build Order

## 1. `bend` Lens Modifiers (NOT pipe steps)
```nix
# bend.annotate wraps the pipeline:
bend.annotate loc (bend.pipe [ merge type ])

# bend.ensure wraps the type lens:
bend.ensure pred msg T

# bend.map / bend.parse require a lens as 2nd arg:
bend.map f bend.identity
bend.parse refine bend.identity
```
- `bend.nonEmpty.get [a b c]` returns `{ right = { head = a; tail = [b c]; }; }` (NOT a list — never feed into `_hp`/`map`).

## 2. `_normDef` & Merge Laws
```nix
# Preserve def.name via attrset merge:
_normDef = file: def:
  let v = def.value;
  in { name = def.name; inherit file; } //
     (if isAttrs v && v._zenDef or false
      then { inherit (v) value priority; }
      else { value = v; priority = def.priority or 100; });

# Extract _uniqueMerge to avoid forward-referencing merges.unique:
_uniqueMerge = bend.parse (defs:
  let filtered = _hp defs;
  in if length filtered == 1
     then bend.right (head filtered).value
     else bend.left { conflict = filtered; }
) bend.identity;

merges = {
  unique = _uniqueMerge;
  negotiated = { loc }: { get = defs: let r = _uniqueMerge.get defs; in ...; };
};
```
*(Note: `_hp []` throws on `head []`; `_validateAll` MUST inject static defaults before invoking merge.)*

## 3. Eval & `ned.run` Laws
```nix
# Capture sources.config inside cycle-c so drv runs ONCE (not twice):
sinks = ned.run { config = drv; }
  (sources:
    let mod-st = ...;
    in { config = mod-st; result = sources.config; });
in { config = sinks.result; }

# Module stream via ned juxtaposition:
base-st = ned.st.fromList mods
  (ned.st.flatMap ({ file, module }:
    (module sources.config) (ned.st.map (_normDef file))
  ));
```

## 4. Dependent Types & Capabilities
- Dependent type receives the **parsed value** of its parent dependency (NOT ambient `config`):
```nix
options.port = zen.mkOption {
  type = zen.types.dependent zen.types.str
    (protocol: zen.types.refined zen.types.int
      (n: n >= 1 && n <= (if protocol == "tcp" then 65535 else 1023))
      "port out of range for protocol");
};
```
- Capabilities: stream order = module list order -> declare in schema/top-level or collect in two passes. (`zen:namespace` requires `_normDef` to emit `fx.send "zen:namespace" {}` before wiring.)

## 5. 12-Phase Build Order
`0: scaffold` -> `1: primitives (mkOption/merges/types)` -> `2: eval core (ned.run + _validateAll)` -> `3: DI (ctx-d + scope-d)` -> `4: conditions (zero throw)` -> `5: effectful defaults (zen:resolve + cycle detection)` -> `6: apply layer` -> `7: submodules (_subModuleLens + fx.rotate)` -> `8: two-pass capabilities` -> `9: wildcards/dependent/streams` -> `10: fleet demo` -> `11: benchmarks + docs`.
