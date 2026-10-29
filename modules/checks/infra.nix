# infra checks: facts that host data states, compared with each realized NixOS config (fleet flake/infra.nix).
# `checks.x86_64-linux.infra-<host>` fails with the facts that do not hold, so a host never drifts from its data.
{
  yen,
  lib,
  inputs,
  ...
}:
let
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  # a fact: { path; eq; } or { path; has; via ? id; } (`via` maps each realized list item first)
  holdsIn =
    cfg: f:
    let
      got = lib.attrByPath f.path null cfg;
    in
    if f ? has then lib.isList got && lib.elem f.has (map (f.via or (x: x)) got) else got == f.eq;
  check =
    h: cfg: facts:
    let
      bad = lib.filter (f: !holdsIn cfg f) facts;
    in
    pkgs.runCommand "infra-${h}" { } (
      if bad == [ ] then
        "touch $out"
      else
        "echo ${lib.escapeShellArg "infra ${h}: ${lib.concatMapStringsSep "; " (f: lib.concatStringsSep "." f.path) bad}"}; exit 1"
    );
  fact = path: eq: { inherit path eq; };
in
{
  yen.kinds.fleet.sinks.infra = {
    reduce = yen.lib.reduce.merge;
    out =
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
        persist ? { },
        ...
      }:
      {
        ${host.name} = {
          hostname = fact [ "networking" "hostName" ] host.name;
        }
        // lib.optionalAttrs (host.keyboard == "macos") {
          keyd = fact [ "services" "keyd" "enable" ] true;
        }
        // lib.optionalAttrs (host.gpu == "nvidia") {
          nvidia = {
            path = [
              "services"
              "xserver"
              "videoDrivers"
            ];
            has = "nvidia";
          };
        }
        // lib.optionalAttrs (lib.elem "enthium" host.layouts) {
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
            ) (persist.directories or [ ])
          )
        );
      };
  };
}
