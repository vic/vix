# Custom homeManager classes (den.batteries.forward):
#   hm       -> homeManager on Darwin and non-iso Linux hosts
#   hmLinux  -> homeManager on Linux hosts
#   hmDarwin -> homeManager on Darwin hosts
{
  den,
  vic,
  lib,
  ...
}:
let
  # forward `hm${suffix}` for each suffix into homeManager while `enabled stdenv suffix`.
  # guard requests inputs'/self' so forwarded hm modules can take them as args.
  forward =
    each: enabled:
    { aspect-chain, ... }:
    den.batteries.forward {
      inherit each;
      fromClass = suffix: "hm${suffix}";
      intoClass = _: "homeManager";
      intoPath = _: [ ];
      fromAspect = _: lib.head aspect-chain;
      adaptArgs =
        { config, ... }:
        {
          osConfig = config;
        };
      guard = lib.setFunctionArgs (args: suffix: lib.mkIf (enabled args.pkgs.stdenv suffix)) {
        pkgs = false;
        "inputs'" = false;
        "self'" = false;
      };
    };
in
{
  den.classes = {
    hm.description = "homeManager on Darwin and non-iso Linux hosts";
    hmLinux.description = "homeManager on Linux hosts";
    hmDarwin.description = "homeManager on Darwin hosts";
  };

  vic.everywhere.includes = [ vic.classes ];

  vic.classes.includes = [
    vic.hmPlatforms
    vic.hm
  ];

  vic.hmPlatforms = forward [ "Linux" "Darwin" ] (
    stdenv: platform: stdenv.hostPlatform."is${platform}"
  );

  vic.hm =
    { host, ... }: forward [ "" ] (stdenv: _: stdenv.isDarwin || (stdenv.isLinux && !host.iso));
}
