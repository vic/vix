# jujutsu: identity, ssh signing, jjui wrappers.
{
  inputs,
  ren,
  ...
}:
let
  vix = ren.helpers;
in
{

  ren.aspects.jujutsu = {
    dots.".config/jjui" = "config/jjui";
    at = ren.aspects.vic-headless;
    flake-inputs =
      { ... }:
      {
        jjui = {
          url = "github:idursun/jjui";
          inputs.flake-parts.follows = "flake-parts";
          inputs.nixpkgs.follows = "nixpkgs";
        };
        flake-parts = {
          url = "github:hercules-ci/flake-parts";
          inputs.nixpkgs-lib.follows = "nixpkgs-lib";
        };
        nixpkgs-lib.follows = "nixpkgs";
      };
    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        jjui = (vix.perSystem pkgs inputs.jjui).packages.jjui;
        jjui-wrapped = pkgs.writeShellApplication {
          name = "jjui";
          text = ''
            # ask for password if key is not loaded, before jjui
            ssh-add -l || ssh-add
            ${pkgs.lib.getExe jjui} "$@"
          '';
        };

        majjit = (vix.perSystem pkgs inputs.jjui).packages.jjui;
        majjit-wrapped = pkgs.writeShellApplication {
          name = "majjit";
          text = ''
            # ask for password if key is not loaded, before jjui
            ssh-add -l || ssh-add
            ${pkgs.lib.getExe majjit} "$@"
          '';
        };
      in
      {
        home.packages = [
          jjui-wrapped
          majjit-wrapped
          (inputs.nix-wrapper-modules.wrappers.jujutsu.wrap {
            inherit pkgs;
            settings = config.programs.jujutsu.settings;
          })
        ];
        programs.jujutsu = {
          settings = {
            user.name = user.fullName;
            user.email = user.email;
            revsets.log = "default()";
            signing = {
              behaviour = "own";
              backend = "ssh";
              key = "~/.ssh/id_ed25519.pub";
            };
          };
        };
      };
  };
}
