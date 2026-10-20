# readme vocabulary (a fn of ren and vocab): markdown tables rendered from live Ren names, each checked against docs/_vocabulary.nix.
{ ren, vocab }:
let
  inherit (builtins)
    attrNames
    concatStringsSep
    filter
    ;
  described = import ./_described.nix "_vocabulary.nix";
  row = cells: "| ${concatStringsSep " | " cells} |";
  # one row of cells per name, under a header row
  table =
    head: cells: names:
    concatStringsSep "\n" (
      map row (
        [
          head
          (map (_: "---") head)
        ]
        ++ map cells names
      )
    );
  code = n: "`${n}`";
  instances =
    k:
    let
      ns = attrNames (ren.${k} or { });
    in
    if ns == [ ] then "- (abstract)" else concatStringsSep ", " ns;
  live = what: filter (n: ren.aspects ? ${n}) (attrNames vocab.${what}); # aspects: stale lines only
  profiles =
    map (t: [
      (code t)
      vocab.tiers.${t}
    ]) (described "tiers" (live "tiers") vocab.tiers)
    ++ map (r: [
      "role `${r}`"
      vocab.roles.${r}
    ]) (described "roles" (live "roles") vocab.roles);
in
''
  ### Kinds: one scope per instance when some `below` lists the kind

  ${table [ "kind" "what it is" "instances (`ren.<kind>.<name>`)" ] (k: [
    (code k)
    vocab.kinds.${k}
    (instances k)
  ]) (described "kinds" (attrNames ren.kinds) vocab.kinds)}

  ### Classes: module systems an aspect key names

  ${table [ "class" "builds" ] (c: [
    (code c)
    vocab.classes.${c}
  ]) (described "classes" (attrNames ren.classes) vocab.classes)}

  ### Channels: data an aspect key emits and a receiver folds

  ${table [ "channel" "emitted by" "received by" ] (c: [ (code c) ] ++ vocab.channels.${c}) (
    described "channels" (attrNames ren.channels) vocab.channels
  )}

  ### vic profiles: tiers gate features (`at = ren.aspects.vic-<tier>`); roles are included or derived

  ${table [ "name" "active" ] (p: p) profiles}

  ${toString (builtins.length (attrNames ren.aspects))} aspects live under `modules/`; `ren.aspects.<name>` each.
''
