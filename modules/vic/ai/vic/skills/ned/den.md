# NED: DEN FLEET-DEMO COMPAT ✅ (81/81 PASS)

## STRUCTURE (v3)

**CORE FILES (UNCHANGED):**
- kernel.nix: run, st, lens, ctx-s, ctx-d, scope-d, fanout-d
- default.nix: imports kernel, bend arg = no `{lib}` destructure
- flake.nix: flakeModule sets _module.args.ned + bend

**FLEET-DEMO TEST FILES (NEW):**
- templates/ci/modules/tests/nixos/fleet-demo/default.nix: ci opt + fleet-demo opt
- templates/ci/modules/tests/nixos/fleet-demo/infra-d.nix: 4 hosts, 2 envs
- templates/ci/modules/tests/nixos/fleet-demo/host-c.nix: role-aware (lb=haproxy, web=nginx)
- templates/ci/modules/tests/nixos/fleet-demo/user-c.nix: SSH keys, tagged {hostName, module}
- templates/ci/modules/tests/nixos/fleet-demo/tests.nix: outer-c, 7 asserts

**CI DEFAULT.NIX CHANGE:**
- added `config._module.args.ci = config.ci` + `options.ci` freeform opt

## JUXTAPOSITION = CORE RULE 🪨

✅ `x (st.flatMap ...)` NOT `x.flatMap(...)`
✅ `st.fromList list` NOT `st list` (list = single elem, not spread)
✅ juxtaposition = space between stream & combinator

## DEN→NED MAPPING

| Den | Ned |
|-----|-----|
| pipe.collect (env scope) | toList + lib.groupBy + st.fromList re-stream |
| parametric aspects {host,...} | host-c { inherit host http-backends host-addrs; } |
| scope hierarchy flake→env→host→user | nested st.fromList + st.flatMap |
| per-host instantiation | make-system filters stream by hostName |
| two-phase pipeline | Phase1: toList gather / Phase2: st.fromList scatter |

## ENV-SCOPED PIPE PATTERN (KEY)

```nix
# gather
all-hosts = sources.infra.toList;
by-env = lib.groupBy (h: h.environment) all-hosts;

# scatter w/ peer ctx
(st.fromList (builtins.attrValues by-env)) (st.flatMap (env-hosts:
  let
    http-backends = map (h: {...}) (filter (h: h.role == "web") env-hosts);
    host-addrs    = map (h: {...}) env-hosts;
  in
  (st.fromList env-hosts) (st.flatMap (host:
    (host-c { inherit host host-addrs; http-backends = ...; }).host-config
  ))
))
```

## USER-CONFIG TAG PATTERN

user-c returns `{ hostName = host.name; module = {...}; }` not raw module.
make-system filters: `st.filter (e: e.hostName == host-name)` then `st.map (e: e.module)`.
Prevents key duplication when user appears on multiple hosts.

## TEST RUNNER

```
nix eval --impure --expr "(import /home/vic/hk/ned/templates/ci/tests.nix)" --apply '...'
```
NOT `nix eval .#tests` (uses locked remote ned, not local).

## INSIGHT

Ned laziness + toList as explicit gather boundary = Den's trampoline+effects in 3 lines.
No new Ned primitives needed for full fleet-demo support.
