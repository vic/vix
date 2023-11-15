{ channels', pkgs, lib, config, ... }:
let
  latestDrv = channels'.nix-latest.nix;
  latestClosure = pkgs.stdenvNoCC.mkDerivation {
    pname = "nix-closure";
    version = latest.version;
    src = builtins.fetchClosure {
      fromPath = latest.outPath;
      fromStore = "https://cache.nixos.org";
      inputAddressed = true;
    };
    installPhase = ''
      ln -s $src $out
    '';
  };
  latest = latestDrv;
  allNix = {
    nix = latest;
    nixUnstable = latest;
  };
  cfg = config.vix.features.nix-latest;

  inherit (lib) mkIf mkEnableOption;
in
{
  options.vix.features.nix-latest.enable = mkEnableOption "Use latest nix";
  config = mkIf cfg.enable {
    nixpkgs.overlays = [ (self: super: allNix) ];
  };
}
