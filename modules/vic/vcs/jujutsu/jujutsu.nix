# jujutsu: identity, ssh signing, jjui + majjit wrappers.
{ yen, inputs, ... }:
let
  # ask for the ssh key password if it is not loaded, before the tui
  wrapped =
    pkgs: name: tui:
    pkgs.writeShellApplication {
      inherit name;
      text = ''
        # ask for password if key is not loaded, before jjui
        ssh-add -l || ssh-add
        ${pkgs.lib.getExe tui} "$@"
      '';
    };
in
{
  yen.aspects.jujutsu = {
    at = yen.aspects.vic-headless;
    dots.".config/jjui" = "config/jjui";
    flake-file.inputs = {
      jjui = {
        url = "github:idursun/jjui";
        inputs.flake-parts.follows = "flake-parts";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      majjit = {
        url = "github:anthrofract/majjit";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      };
      nixpkgs-lib.follows = "nixpkgs";
      nix-wrapper-modules = {
        url = "github:nix-community/nix-wrapper-modules";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };
    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        jjui = (yen.helpers.perSystem pkgs inputs.jjui).packages.jjui;
        majjit = (yen.helpers.perSystem pkgs inputs.majjit).packages.majjit;
      in
      {
        home.packages = [
          (wrapped pkgs "jjui" jjui)
          (wrapped pkgs "majjit" majjit)
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
