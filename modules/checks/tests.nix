# tests: pure-eval assertions over the built configs, each a flake check (empty problem list => ok).
{ sven, lib, ... }:
let
  vicHome = c: lib.attrByPath [ "home-manager" "users" "vic" ] { home.packages = [ ]; } c.config;
  hasPkg = name: ps: builtins.any (p: lib.getName p == name) ps;
  # every host is checked, known-broken ones too: only packages available on the host platform are allowed
  mismatch =
    platform: ps:
    map (p: "${lib.getName p} not available on ${platform.system}") (
      builtins.filter (p: !lib.meta.availableOn platform p) ps
    );
  # names come from the instances, not from `out`: the check names never force the outputs they judge
  platforms =
    instances: configs:
    lib.mapAttrs' (
      host: _:
      let
        c = configs.${host};
      in
      lib.nameValuePair "platform-packages-${host}" (
        mismatch c.pkgs.stdenv.hostPlatform (
          c.config.environment.systemPackages ++ (vicHome c).home.packages or [ ]
        )
      )
    ) instances;
  problems =
    out:
    let
      nargun = vicHome out.nixosConfigurations.nargun;
      varda = vicHome out.darwinConfigurations.varda;
    in
    {
      math-works = lib.optional (2 * 11 != 22) "math is broken";
      nargun =
        lib.optional (!hasPkg "ghostty" nargun.home.packages) "ghostty missing"
        ++ lib.optional (!hasPkg "gparted" nargun.home.packages) "gparted missing"
        ++ lib.optional (nargun.home.sessionVariables.NH_FILE == null) "NH_FILE unset";
      darwin-iterm2 = lib.optional (!hasPkg "iterm2" varda.home.packages) "iterm2 missing";
    }
    // platforms sven.host out.nixosConfigurations
    // platforms sven.mac out.darwinConfigurations;
in
{
  sven.aspects.config-tests = {
    at = sven.system.x86_64-linux;
    checks =
      { system, out, ... }:
      {
        ${system.name} = lib.mapAttrs (
          name: ps:
          system.legacyPackages.runCommand name { } ''
            ${lib.concatMapStringsSep "\n" (p: "echo ${lib.escapeShellArg p}") ps}
            ${if ps == [ ] then "touch $out" else "exit 1"}
          ''
        ) (problems out);
      };
  };
}
