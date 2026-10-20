# direnv: nix-direnv with vix lib helpers; hosts keep devshell closures alive across GC.
{
  ren,
  inputs,
  ...
}:
let
  use_nix_installables = ''
    use_nix_installables() {
      direnv_load nix shell "''${@}" -c $direnv dump
    }
  '';
  use_vix_go = ''
    use_vix_go() {
      use nix_installables ${inputs.nixpkgs}#go ${inputs.nixpkgs}#gopls
    }
  '';
in
{
  ren.aspects.direnv = {
    at = ren.aspects.vic-headless;
    homeManager = {
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
      home.file.".config/direnv/lib/use_nix_installables.sh".text = use_nix_installables;
      home.file.".config/direnv/lib/use_vix_go.sh".text = use_vix_go;
    };
  };

  # keep devshell closures alive across GC (sini direnv.nix:4-7), on every machine vic uses
  ren.aspects.direnv-host = {
    at = ren.lib.and [
      ren.kinds.machine
      (ren.lib.has ren.user.vic)
    ];
    os = {
      nix.settings.keep-outputs = true;
      nix.settings.keep-derivations = true;
    };
  };
}
