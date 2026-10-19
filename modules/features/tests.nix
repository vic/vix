# tests: pure-eval assertions over the built configs, each a flake check (empty problem list => ok).
{
  ren,
  inputs,
  pkgsFor,
  ...
}:
let
  inherit (inputs.nixpkgs) lib;
  self = inputs.self; # shortcut: reads configs back from flake outputs, lazily
  skipped = [
    "mordor" # unfree nvidia driver
    "yavanna" # x86_64-darwin dropped by nixpkgs
    "varda" # openspec
  ];
  skipPkgs.bombadil = [ "zfs" ];
  vicHome = c: lib.attrByPath [ "home-manager" "users" "vic" ] { home.packages = [ ]; } c.config;
  hasPkg = name: ps: builtins.any (p: lib.getName p == name) ps;
  mismatch =
    host: system: ps:
    map (p: "${lib.getName p} not in system: ${system}") (
      builtins.filter (
        p:
        !(
          builtins.elem (lib.getName p) (skipPkgs.${host} or [ ])
          || builtins.elem system (p.meta.platforms or [ system ])
        )
      ) ps
    );
  platforms =
    configs: sys:
    lib.mapAttrs' (
      host: c:
      lib.nameValuePair "platform-packages-${host}" (
        mismatch host (sys c) (c.config.environment.systemPackages ++ (vicHome c).home.packages or [ ])
      )
    ) (lib.filterAttrs (n: _: !builtins.elem n skipped) configs);
  nargun = vicHome self.nixosConfigurations.nargun;
  varda = vicHome self.darwinConfigurations.varda; # yavanna is x86_64-darwin: dropped by nixpkgs
  problems = {
    math-works = lib.optional (2 * 11 != 22) "math is broken";
    nargun =
      lib.optional (!hasPkg "ghostty" nargun.home.packages) "ghostty missing"
      ++ lib.optional (!hasPkg "gparted" nargun.home.packages) "gparted missing"
      ++ lib.optional (nargun.home.sessionVariables.NH_FILE == null) "NH_FILE unset";
    darwin-iterm2 = lib.optional (!hasPkg "iterm2" varda.home.packages) "iterm2 missing";
  }
  // platforms self.nixosConfigurations (c: c.pkgs.stdenv.hostPlatform.system)
  // platforms self.darwinConfigurations (c: c.pkgs.stdenv.hostPlatform.system);
in
{
  ren.aspects.config-tests = {
    at = ren.system.x86_64-linux;
    checks =
      { system, ... }:
      {
        ${system.name} = lib.mapAttrs (
          name: ps:
          (pkgsFor system).runCommand name { } ''
            ${lib.concatMapStringsSep "\n" (p: "echo ${lib.escapeShellArg p}") ps}
            ${if ps == [ ] then "touch $out" else "exit 1"}
          ''
        ) problems;
      };
  };
}
