{ pkgs, perSystem, ... }:
let

  ssh_config_text = ''
    Host *
      ForwardAgent yes
      ForwardX11 yes
      ForwardX11Trusted yes
      StrictHostKeyChecking no
      CheckHostIP no
      TCPKeepAlive yes
      ServerAliveInterval 30
      ServerAliveCountMax 180
      VerifyHostKeyDNS yes
      UpdateHostKeys yes
  '';

  gh-action = pkgs.writeShellApplication {
    name = "gh-action";
    runtimeInputs = [
      pkgs.upterm
      pkgs.screen
      pkgs.openssh
      pkgs.bash
      pkgs.coreutils
      pkgs.findutils
      pkgs.gawk
    ] ++ (pkgs.lib.optionals (pkgs.config.allowUnfree) [ pkgs.vscode ]);
    text = ''
      mkdir -p ~/.ssh
      echo "${ssh_config_text}" > ~/.ssh/config
      ${pkgs.openssh}/bin/ssh-agent ${pkgs.bash}/bin/bash ${./upterm/gh-action.bash}
    '';
  };

in
perSystem.devshell.mkShell {

  devshell.packages = [ gh-action ];

}
