# fleet classes (part of docs/_fleet-ir.nix): static class forwarding; `live` edges carry instance names read from Ren.
{
  ren,
  id,
  uniq,
  hosts,
  macs,
  guests,
  homes,
}:
let
  inherit (builtins)
    attrNames
    concatMap
    concatStringsSep
    elem
    filter
    throw
    ;
  names = xs: concatStringsSep ", " (map (x: x.name) xs);
  e = live: from: to: label: {
    inherit
      live
      from
      to
      label
      ;
  };
  fwd = [
    (e false "homeLinux" "homeManager" "on linux")
    (e false "homeDarwin" "homeManager" "on darwin")
    (e true "homeManager" "nixos" (names (filter (h: h.users != [ ]) hosts)))
    (e true "homeManager" "darwin" (names (filter (m: m.users != [ ]) macs)))
    (e true "homeManager" "homeConfigurations" (
      concatStringsSep ", " (map (h: "${h.user.name}@${h.name}") homes)
    ))
    (e false "os" "nixos" "")
    (e false "os" "darwin" "")
    (e false "account" "nixos" "users.users")
    (e false "account" "darwin" "users.users")
    (e true "nixos" "microvm.vms"
      "${names guests} in ${concatStringsSep ", " (attrNames (builtins.groupBy (g: g.on.name) guests))}"
    )
    (e true "nixos" "nixosConfigurations" (names hosts))
    (e true "darwin" "darwinConfigurations" (names macs))
    (e true "vim" "packages" (concatStringsSep ", " (attrNames ren.vim)))
    (e false "files" "packages" "write-files")
    (e false "files" "checks" "files/README.md")
    (e false "flake-file" "packages" "write-flake")
    (e false "flake-file" "checks" "flake-file")
  ];
  froms = map (x: x.from) fwd;
  # every live class is drawn, every drawn source is a live class
  bad =
    filter (c: !(elem c froms)) (attrNames ren.classes) ++ filter (c: !(ren.classes ? ${c})) froms;
  node = s: {
    id = id s;
    label = s;
    kind = if ren.classes ? ${s} then "class" else "output";
    group = null;
  };
in
if bad == [ ] then
  {
    nodes = uniq (
      concatMap (x: [
        (node x.from)
        (node x.to)
      ]) fwd
    );
    edges = map (
      x:
      x
      // {
        from = id x.from;
        to = id x.to;
      }
    ) fwd;
  }
else
  throw "docs/_fleet-classes.nix: unknown or undrawn classes [${toString bad}]"
