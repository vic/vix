# readme vocabulary: markdown tables rendered from live Ren names, each checked against docs/vocabulary.nix.
{
  ren,
  vocab,
  vicAt,
  ...
}:
let
  inherit (builtins)
    attrNames
    concatStringsSep
    elem
    filter
    throw
    ;
  # live names, or an eval error naming every missing and stale description.
  described =
    what: names: lines:
    let
      missing = filter (n: !(lines ? ${n})) names;
      stale = filter (n: !(elem n names)) (attrNames lines);
    in
    if missing == [ ] && stale == [ ] then
      names
    else
      throw "docs/vocabulary.nix ${what}: missing [${toString missing}] stale [${toString stale}]";
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
  rolesLive = filter (n: ren.aspects ? ${n}) (attrNames vocab.roles);
  profiles =
    map (t: [
      "`vicAt.${t}`"
      vocab.tiers.${t}
    ]) (described "tiers" (attrNames vicAt) vocab.tiers)
    ++ map (r: [
      "role `${r}`"
      vocab.roles.${r}
    ]) (described "roles" rolesLive vocab.roles);
in
{
  _module.args.readmeVocab = ''
    ## Vix vocabulary

    ### Kinds: typed data; a kind some `below` lists gets one scope per instance

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

    ### vic profiles: `at = vicAt.<tier>` gates vic's features; roles are aspects machines include or derive

    ${table [ "name" "active" ] (p: p) profiles}

    ${toString (builtins.length (attrNames ren.aspects))} aspects live under `modules/`; `ren.aspects.<name>` each.
  '';
}
