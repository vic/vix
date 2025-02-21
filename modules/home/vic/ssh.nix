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
  };

  services.ssh-agent.enable = pkgs.stdenv.isLinux;

  home.file.".ssh/id_ed25519.pub".source = ./secrets/ssh/vic_mordor.pub;
  home.activation.link_ssh_id = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ln -sf "${config.sops.secrets."ssh/id_ed25519".path}" $HOME/.ssh/id_ed25519
  '';
}
