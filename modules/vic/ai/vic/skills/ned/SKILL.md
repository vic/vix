NED IS CYCLE.js INSPIRED

* EVERYTHING IS CYClE OR DRIVER
* ALL DATA ACCESS VIA STREAMS
* CONVENTION: CYCLE -C; STREAM -S; DRIVER -D;
* DRIVER: STREAM -> STREAM
* CYCLE: sources->responses (attrs-of stream)
* STREAM: st op op; juxtaposition
* CTXFN: st ({ x }: { ... }) requests x from ctx-d

## JUXTAPOSITION = CORE RULE 🪨

✅ **SYNTAX: x (st.flatMap ...) NOT x.flatMap (...)**
- `.flatMap` = VIOLATION (method syntax)
- `(st.flatMap ...)` = CORRECT (juxtaposition)
- space between stream & combinator = juxtapose
- dot between stream & method = FORBIDDEN

✅ **PATTERN (MANDATORY):**
- infra (st.flatMap fn) = juxtapose stream + combinator
- st config1 config2 = juxtapose multiple values
- NO .map, .filter, .flatMap, .fromList method calls
- st {...} = direct value (no fromList)
- All combiTnators passed as separate args via juxtaposition

## NED.RUN PATTERN

✅ **run {infra = infra-d} outer-c**
1. run calls outer-c with sources from drivers
2. outer-c receives sources.infra (host stream)
3. outer-c uses juxtaposition (st (...)), NOT method chains
   - NO .flatMap(...).flatMap(...)
   - host-configs = st (sources.infra.flatMap (host → (host-c {...}).host-config))
   - user-configs = st (sources.infra.flatMap (host → users.flatMap (user → (user-c {...}).user-config)))
4. extract config directly: (cycle).field, not flatMap result
5. return { infra = st null, host-configs, user-configs }
6. apply collectors (terminal ops on sinks)
7. compose defaults-s + collected → module-s
8. ONLY .toList at EDGE: module-s.toList for nixos system

## ISOLATION

✅ **ZERO COUPLING:** cycles standalone, only need params
✅ **STREAMS ONLY:** all data via st (sources → sinks → sources)
✅ **SEPARATE CONCERNS:** host/user cycles independent
✅ **PARAMETRIC:** no {host}, {user} ctx magic
✅ **CLEAN COLLECTION:** collectors aggregate without side effects

## CLEANUP DONE

