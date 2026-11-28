# Stored queries: named questions runnable from CLI via `nix eval --json .#yen.ask.<name> --apply 'f: f { ... }'`.
{
  yen,
  lib,
  ...
}:
let
  b = builtins;
  placeKinds = [
    "host"
    "guest"
    "mac"
    "home"
  ];
  placeMatches =
    p: s:
    if b.isString p then
      s.ref.name == p && b.elem (lib.last s.ref.kind) placeKinds
    else if b.isAttrs p && p ? __inst then
      s.ref.kind == p.__inst.kind && s.ref.name == p.__inst.name
    else
      s.ref.name == (p.name or "");
  placeNameOf =
    p:
    if b.isString p then
      p
    else if b.isAttrs p && p ? __inst then
      p.__inst.name
    else
      p.name or (toString p);
  vimNameOf =
    v:
    if b.isString v then
      v
    else if b.isAttrs v && v ? __inst then
      v.__inst.name
    else
      v.name or (toString v);
  under =
    r: p:
    lib.concatMap (
      s: map (x: x.id) (lib.filter (x: x.id == s.id || lib.hasPrefix "${s.id}/" x.id) r.scopes)
    ) (lib.filter (placeMatches p) r.scopes);
  portsOf =
    result: p:
    lib.concatMap (
      id: lib.concatMap (e: map (x: x // { at = id; }) e.value) (result.reduced.ports.${id} or [ ])
    ) (under result p);
in
{
  yen.helpers.portsOf = portsOf;
  yen.queries = {
    fleetSummary = {
      answer =
        { result }:
        {
          hosts = lib.sort lib.lessThan (b.attrNames (result.data.host or { }));
          macs = lib.sort lib.lessThan (b.attrNames (result.data.mac or { }));
          homes = lib.sort lib.lessThan (b.attrNames (result.data.home or { }));
          envs = lib.sort lib.lessThan (b.attrNames (result.data.env or { }));
          vims = lib.sort lib.lessThan (b.attrNames (result.data.vim or { }));
          kits = lib.sort lib.lessThan (b.attrNames (result.schema.kits or { }));
          assemblies = lib.sort lib.lessThan (b.attrNames (result.schema.assemblies or { }));
        };
    };
    aspectsOn = {
      params.place = yen.kinds.place;
      answer =
        { result, place }:
        lib.genAttrs (under result place) (
          id: lib.filter (a: result.active.${a}.${id} or false) (lib.attrNames result.active)
        );
    };
    unfreeOn = {
      params.place = yen.kinds.place;
      answer =
        { result, place }:
        map
          (e: {
            inherit (e) aspect to;
          })
          (
            lib.filter (
              e: e.sink == "unfree" && !(e.isForward or false) && lib.elem e.to (under result place)
            ) result.graph.edges
          );
    };
    portsOf = {
      params.place = yen.kinds.place;
      answer = { result, place }: portsOf result place;
    };
    featuresOf = {
      params.vim = yen.kinds.vim;
      answer =
        { result, vim }:
        (
          vName:
          (vData: {
            features = map (f: f.name or (toString f)) (vData.features or [ ]);
            inherit (vData) theme gui aliases;
            aspects = lib.unique (
              map (e: e.aspect) (
                lib.filter (
                  e: e.sink == "nvf" && lib.hasSuffix "/system:x86_64-linux/vim:${vName}" e.to
                ) result.graph.edges
              )
            );
          })
            result.data.vim.${vName}
        )
          (vimNameOf vim);
    };
    freePort = {
      params.place = yen.kinds.place;
      answer =
        { result, place }:
        (
          used:
          (
            free:
            if free == [ ] then
              {
                error = "no free port on ${placeNameOf place} in 8000..8999";
                inherit used;
              }
            else
              {
                port = lib.head free;
                inherit used;
              }
          )
            (lib.filter (p: !(b.elem p used)) (lib.range 8000 8999))
        )
          (map (p: p.port) (portsOf result place));
    };
  };
}
