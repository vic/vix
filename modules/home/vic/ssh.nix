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
    controlPath = "~/.ssh/%h:%C";
    forwardAgent = true;

    # on server
    #settings.PasswordAuthentication = false;
    #settings.KdbInteractiveAuthentication = false;
    #settings.PermitRootLogin = "no";

    extraConfig = ''
      Include ~/.config/sops-nix/secrets/ssh/sops_ssh_config
    '';
  };

  services.ssh-agent.enable = pkgs.stdenv.isLinux;

  home.activation.link-ssh-id = lib.hm.dag.entryAfter [ "link-flake" "sops-nix" ] ''
    run ln -sf "${config.sops.secrets."ssh/id_ed25519".path}" $HOME/.ssh/id_ed25519
  '';
}
