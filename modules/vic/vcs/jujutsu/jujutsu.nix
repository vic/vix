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
          url = "github:idursun/jjui/151c7c51bf5b2cf49ea9ccdcde8ef98538f59787";
          inputs.flake-parts.follows = "flake-parts";
          inputs.nixpkgs.follows = "nixpkgs";
        };
        flake-parts = {
          url = "github:hercules-ci/flake-parts/024633cd702b10285db5cb19b40ad48d2399ba60";
          inputs.nixpkgs-lib.follows = "nixpkgs-lib";
        };
        nixpkgs-lib.follows = "nixpkgs";
      };
    homeManager =
      {
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
        ];
        programs.jujutsu = {
          enable = true;
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
