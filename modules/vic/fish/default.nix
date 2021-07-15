{config, lib, pkgs, USER, DOTS, ...}:
{
  
  home-manager.users.${USER} = {

    programs.fish = {
      enable = true;
    };

    home.file = {
      ".local/share/fish/fish_history".source = "${DOTS}/fish/fish_history";
    };

  };

}