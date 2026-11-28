# infra checks: ref-typed host facts verified against realized NixOS configs (`checks.x86_64-linux.infra-<host>`).
{
  yen,
  reduce,
  lib,
  inputs,
  ...
}:
let
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  holdsIn =
    cfg: f:
    (got: if f ? has then lib.isList got && lib.elem f.has (map (f.via or (x: x)) got) else got == f.eq)
      (lib.attrByPath f.path null cfg);
  check =
    h: cfg: facts:
    (
      bad:
      pkgs.runCommand "infra-${h}" { } (
        if bad == [ ] then
          "touch $out"
        else
          "echo ${lib.escapeShellArg "infra ${h}: ${lib.concatMapStringsSep "; " (f: lib.concatStringsSep "." f.path) bad}"}; exit 1"
      )
    )
      (lib.filter (f: !holdsIn cfg f) facts);
  fact = path: eq: { inherit path eq; };
in
{
  yen.kinds.root.sinks.infra = {
    reduce = reduce.merge;
    into.out =
      { infra, out, ... }:
      {
        checks.x86_64-linux = lib.mapAttrs' (
          h: facts:
          lib.nameValuePair "infra-${h}" (check h out.nixosConfigurations.${h}.config (lib.attrValues facts))
        ) infra;
      };
  };

  yen.aspects.infra-facts = {
    at = yen.kinds.host;
    infra =
      {
        host,
        persist ? [ ],
        ...
      }:
      (persistDirs: {
        ${host.name} = {
          hostname = fact [ "networking" "hostName" ] host.name;
        }
        // lib.optionalAttrs (yen.lib.same host.keyboard yen.keyboard.macos) {
          keyd = fact [ "services" "keyd" "enable" ] true;
        }
        // lib.optionalAttrs (yen.lib.same host.gpu yen.gpu.nvidia) {
          nvidia = {
            path = [
              "services"
              "xserver"
              "videoDrivers"
            ];
            has = "nvidia";
          };
        }
        // lib.optionalAttrs (lib.any (yen.lib.same yen.layout.enthium) host.layouts) {
          enthium = fact [ "services" "xserver" "xkb" "extraLayouts" "enthium" "description" ] "Enthium";
        }
        // lib.optionalAttrs host.impermanence.enable (
          lib.listToAttrs (
            map (
              d:
              lib.nameValuePair "persist ${d}" {
                path = [
                  "environment"
                  "persistence"
                  "/nix/persist"
                  "directories"
                ];
                has = d;
                via = x: x.directory or x;
              }
            ) persistDirs
          )
        );
      })
        (lib.concatMap (e: if lib.isString e then [ e ] else e.directories or [ ]) persist);
  };
}
