{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    controlMaster = "auto";

    # on server
    #settings.PasswordAuthentication = false;
    #settings.KdbInteractiveAuthentication = false;
    #settings.PermitRootLogin = "no";

    extraConfig = ''
      Host yavanna
        HostName 192.168.1.71
        User vic
        IdentityFile ~/.ssh/id_ed25519
        RequestTTY yes
        RemoteCommand TERM=xterm $SHELL -l
    '';
  };

  services.ssh-agent.enable = pkgs.stdenv.isLinux;

  home.activation.link_ssh_id = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ln -sf "${config.sops.secrets."ssh/id_ed25519".path}" $HOME/.ssh/id_ed25519
  '';
}
