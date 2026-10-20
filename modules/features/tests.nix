# tests: pure-eval assertions over the built configs, each a flake check (empty problem list => ok).
{
  ren,
  inputs,
  ...
}:
let
  inherit (inputs.nixpkgs) lib;
  self = inputs.self; # shortcut: reads configs back from flake outputs, lazily
  vicHome = c: lib.attrByPath [ "home-manager" "users" "vic" ] { home.packages = [ ]; } c.config;
  hasPkg = name: ps: builtins.any (p: lib.getName p == name) ps;
  # every host is checked, known-broken ones too: only packages available on the host platform are allowed
  mismatch =
    platform: ps:
    map (p: "${lib.getName p} not available on ${platform.system}") (
      builtins.filter (p: !lib.meta.availableOn platform p) ps
    );
  platforms = lib.mapAttrs' (
    host: c:
    lib.nameValuePair "platform-packages-${host}" (
      mismatch c.pkgs.stdenv.hostPlatform (
        c.config.environment.systemPackages ++ (vicHome c).home.packages or [ ]
      )
    )
  );
  nargun = vicHome self.nixosConfigurations.nargun;
  varda = vicHome self.darwinConfigurations.varda;
  problems = {
    math-works = lib.optional (2 * 11 != 22) "math is broken";
    nargun =
      lib.optional (!hasPkg "ghostty" nargun.home.packages) "ghostty missing"
      ++ lib.optional (!hasPkg "gparted" nargun.home.packages) "gparted missing"
      ++ lib.optional (nargun.home.sessionVariables.NH_FILE == null) "NH_FILE unset";
    darwin-iterm2 = lib.optional (!hasPkg "iterm2" varda.home.packages) "iterm2 missing";
  }
  // platforms self.nixosConfigurations
  // platforms self.darwinConfigurations;
in
{
  ren.aspects.config-tests = {
    at = ren.system.x86_64-linux;
    checks =
      { system, ... }:
      {
        ${system.name} = lib.mapAttrs (
          name: ps:
          system.legacyPackages.runCommand name { } ''
            ${lib.concatMapStringsSep "\n" (p: "echo ${lib.escapeShellArg p}") ps}
            ${if ps == [ ] then "touch $out" else "exit 1"}
          ''
        ) problems;
      };
  };
}
