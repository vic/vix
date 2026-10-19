# jujutsu: identity, ssh signing, jjui wrappers.
{ vicAt, ... }:
{

  ren.aspects.jujutsu = {
    at = vicAt.core;
    homeManager =
      {
        pkgs,
        inputs',
        user,
        ...
      }:
      let
        jjui = inputs'.jjui.packages.jjui;
        jjui-wrapped = pkgs.writeShellApplication {
          name = "jjui";
          text = ''
            # ask for password if key is not loaded, before jjui
            ssh-add -l || ssh-add
            ${pkgs.lib.getExe jjui} "$@"
          '';
        };

        majjit = inputs'.jjui.packages.jjui;
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
