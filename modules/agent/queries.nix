# Stored queries: named questions with typed parameters (`result.ask.<name> args`).
{
  yen,
  lib,
  ...
}:
let
  b = builtins;
  under =
    r: p:
    lib.concatMap (
      s: map (x: x.id) (lib.filter (x: x.id == s.id || lib.hasPrefix "${s.id}/" x.id) r.scopes)
    ) (lib.filter (s: s.ref.kind == p.__inst.kind && s.ref.name == p.__inst.name) r.scopes);
  portsOf =
    result: p:
    lib.concatMap (
      id: lib.concatMap (e: map (x: x // { at = id; }) e.value) (result.reduced.ports.${id} or [ ])
    ) (under result p);
in
{
  yen.helpers.portsOf = portsOf;
  yen.queries = {
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
        {
          inherit (result.data.vim.${vim.name})
            features
            theme
            gui
            aliases
            ;
          aspects = lib.unique (
            map (e: e.aspect) (
              lib.filter (
                e: e.sink == "nvf" && lib.hasSuffix "/system:x86_64-linux/vim:${vim.name}" e.to
              ) result.graph.edges
            )
          );
        };
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
                error = "no free port on ${place.name} in 8000..8999";
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
