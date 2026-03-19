{
  den,
  vic,
  lib,
  ...
}:
{
  vic.everywhere.includes = [ vic.classes ];

  vic.classes.includes = [
    vic.hmPlatforms
    vic.hm
  ];

  vic.hmPlatforms =
    { aspect-chain, ... }:
    den._.forward {
      each = [
        "Linux"
        "Darwin"
      ];
      fromClass = platform: "hm${platform}";
      intoClass = _: "homeManager";
      intoPath = _: [ ];
      fromAspect = _: lib.head aspect-chain;
      adaptArgs =
        { config, ... }:
        {
          osConfig = config;
        };
      guard = { pkgs, ... }: platform: lib.mkIf pkgs.stdenv."is${platform}";
    };

  vic.hm =
    { host, ... }:
    { aspect-chain, ... }:
    den._.forward {
      each = lib.singleton true;
      fromClass = _: "hm";
      intoClass = _: "homeManager";
      intoPath = _: [ ];
      fromAspect = _: lib.head aspect-chain;
      adaptArgs =
        { config, ... }:
        {
          osConfig = config;
        };
      guard = { pkgs, ... }: _: lib.mkIf (pkgs.stdenv.isDarwin || (pkgs.stdenv.isLinux && !host.iso));
    };
}
