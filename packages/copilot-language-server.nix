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
in
pkgs.buildFHSEnv {
  name = pname;
  targetPkgs = pkgs: [ pkgs.stdenv.cc.cc.lib ];
  runScript = pkgs.lib.getExe p;
}
