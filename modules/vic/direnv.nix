{ inputs, ... }:
let
  flake.modules.homeManager.vic = {
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    home.file.".config/direnv/lib/use_nix_installables.sh".text = use_nix_installables;
    home.file.".config/direnv/lib/use_vix.sh".text = use_vix;
  };

  use_nix_installables = ''
    use_nix_installables() {
      direnv_load nix shell "''${@}" -c $direnv dump
    }
  '';

  use_vix = ''
    use_vix_go() {
      use nix_installables ${inputs.nixpkgs}#go ${inputs.nixpkgs}#gopls
    }
  '';
in
{
  inherit flake;
}
