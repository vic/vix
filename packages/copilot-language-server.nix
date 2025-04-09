{ pname, pkgs, ... }:
let
  p = pkgs.${pname}.overrideAttrs (
    _final: prev: {
      meta = prev.meta // {
        license = prev.meta.license // {
          free = true; # lies!
        };
      };
    }
  );

  cls = pkgs.buildFHSEnv {
    name = pname;
    targetPkgs = pkgs: [ pkgs.stdenv.cc.cc.lib ];
    runScript = pkgs.lib.getExe p;
  };
  
  noop = pkgs.writeShellApplication {
    name = pname;
    text = "echo Not available";
  };
in if pkgs.stdenv.hostPlatform.isLinux then cls else noop
