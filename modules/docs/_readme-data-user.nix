# readme user data (a fn of sven, lib and mermaid): secrets and their consumers, vim profiles, envs, dotfiles.
{
  sven,
  lib,
  mermaid,
}:
let
  g = sven.lib.graph;
  sorted = xs: lib.sort (a: b: a < b) (lib.unique xs);
  code = xs: lib.concatMapStringsSep ", " (x: "`${x}`") (sorted xs);
  row = cells: "| ${lib.concatStringsSep " | " cells} |";
  table =
    head: rows:
    lib.concatStringsSep "\n" (
      map row (
        [
          head
          (map (_: "---") head)
        ]
        ++ rows
      )
    );
  mark = b: if b then "x" else "";
  parentOf = id: lib.concatStringsSep "/" (lib.init (lib.splitString "/" id));
  aspectOf = e: lib.removePrefix "aspect " e.origin;
  given = sink: lib.filter (e: e.sink == sink && lib.hasPrefix "aspect " e.origin) g.edges;
  # a static element, or one an arg-free function gives (`{ ... }: [ .. ]`); else the default d
  value =
    d: v:
    if lib.isFunction v then
      (if lib.all (x: x) (lib.attrValues (builtins.functionArgs v)) then v { } else d)
    else
      v;
  linux = lib.findFirst (s: s.kind == "system" && s.name == "x86_64-linux") null g.scopes;

  # the secrets plan: sops file -> secret -> the aspect that gives it on a `secrets` sink -> where it lands (a user's
  # place, or a host). A `deploy = false` secret reaches no machine: only vic-sops-get and vic-sops-rotate read it.
  fileOf = s: if s.sopsFile == null then "secrets.yaml" else "secrets/${baseNameOf s.sopsFile}";
  declared = lib.attrValues sven.secret;
  asks = lib.genAttrs (sorted (map aspectOf (given "secrets"))) (
    a: map (s: s.name) (lib.filter lib.isAttrs (lib.toList (value [ ] sven.aspects.${a}.secrets)))
  );
  asked = lib.concatLists (lib.attrValues asks);
  # a user's secrets land on its place; a host's on the host
  placeOf = id: if lib.hasPrefix "user:" (lib.last (lib.splitString "/" id)) then parentOf id else id;
  secrets = {
    nodes =
      lib.optional (lib.any (s: !s.deploy) declared) {
        id = "g:tools";
        label = "deploy = false: vic-sops-get, vic-sops-rotate";
        kind = "group";
      }
      ++ map (f: {
        id = "f:${f}";
        label = "modules/vic/${f}";
        kind = "output";
      }) (sorted (map fileOf declared))
      ++ map (s: {
        id = "sec:${s.name}";
        label = s.name;
        kind = "secret";
        group = if s.deploy then null else "g:tools";
      }) declared
      ++ map (a: {
        id = "a:${a}";
        label = a;
        kind = "aspect";
      }) (lib.attrNames asks)
      ++ map (
        p:
        let
          k = lib.splitString ":" (lib.last (lib.splitString "/" p));
        in
        {
          id = p;
          label = lib.last k;
          kind = lib.head k;
        }
      ) (sorted (map (e: placeOf e.to) (given "secrets")));
    edges =
      map (s: {
        from = "f:${fileOf s}";
        to = "sec:${s.name}";
        live = false;
      }) declared
      ++ lib.concatLists (
        lib.mapAttrsToList (
          a:
          map (s: {
            from = "sec:${s}";
            to = "a:${a}";
          })
        ) asks
      )
      ++ lib.unique (
        map (e: {
          from = "a:${aspectOf e}";
          to = placeOf e.to;
        }) (given "secrets")
      );
  };
  # deployable, yet no aspect gives it
  unasked = map (s: s.name) (lib.filter (s: s.deploy && !lib.elem s.name asked) declared);

  vims = lib.attrNames sven.vim;
  vim = table ([ "feature" ] ++ vims) (
    [
      (
        [ "theme" ]
        ++ map (v: lib.optionalString (sven.vim.${v}.theme != null) "`${sven.vim.${v}.theme}`") vims
      )
      (
        [ "gui, aliases" ]
        ++ map (
          v: lib.concatStringsSep " " (lib.optional sven.vim.${v}.gui "gui" ++ sven.vim.${v}.aliases)
        ) vims
      )
    ]
    ++ map (f: [ "`${f}`" ] ++ map (v: mark (lib.elem f sven.vim.${v}.features)) vims) (
      sorted (lib.concatMap (v: sven.vim.${v}.features) vims)
    )
  );

  # env packages as x86_64-linux builds them: each aspect giving to the env scope, called with that scope's env
  envAspects =
    e: sorted (map aspectOf (lib.filter (x: x.from == "${linux.id}/env:${e}") (given "env-packages")));
  envPkgs =
    e: a:
    let
      f = sven.aspects.${a}.env-packages;
    in
    map lib.getName (
      if lib.isFunction f then
        f {
          env = sven.env.${e} // {
            system = sven.system.x86_64-linux;
          };
        }
      else
        f
    );
  env = table [ "env" "langs" "aspects" "packages" ] (
    map (e: [
      "`${e}`"
      (code sven.env.${e}.langs)
      (code (envAspects e))
      (code (lib.concatMap (envPkgs e) (envAspects e)))
    ]) (lib.attrNames sven.env)
  );

  dots = table [ "home path" "modules/vic/dots/" "aspect" ] (
    lib.concatMap (
      a:
      lib.mapAttrsToList (t: s: [
        "`${t}`"
        "`${s}`"
        "`${a}`"
      ]) (value { } sven.aspects.${a}.dots)
    ) (sorted (map aspectOf (given "dots")))
  );
in
''
  **Secrets plan**: sops file (dotted), secret, the aspect that gives it, the machine or home it lands on.
  Declared and deployable, but given by no aspect: ${if unasked == [ ] then "none" else code unasked}.

  ${mermaid secrets}

  <details><summary>vim profiles by feature, envs by lang and package, dotfiles</summary>

  ${vim}

  ${env}

  ${dots}

  </details>
''
