{ pkgs, perSystem, ... }:
let

  ssh_config = ''
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
      pkgs.tmux
      pkgs.openssh
    ] ++ (pkgs.lib.optionals (pkgs.config.allowUnfree) [ pkgs.vscode ]);
    text = ''
      test -n "$GITHUB_REPOSITORY_OWNER"
      # ssh-keygen -q -t rsa -N "" -f ~/.ssh/id_rsa
      # ssh-keygen -q -t ed25519 -N "" -f ~/.ssh/id_ed25519
      echo -e "${ssh_config}" >> ~/.ssh/config
      ssh-keyscan uptermd.upterm.dev 2> /dev/null >> ~/.ssh/known_hosts
      # shellcheck disable=SC2002,SC2094
      cat <(cat ~/.ssh/known_hosts | awk '{ print "@cert-authority * " $2 " " $3 }') >> ~/.ssh/known_hosts
      mkdir -p ~/.upterm
      tmux new -d -s upterm "upterm host --accept --github-user $GITHUB_REPOSITORY_OWNER | grep 'SSH Session:' |  tee ~/.upterm/out.log"
      while ! grep 'SSH Session:' ~/.upterm/out.log; do sleep 1 ; done
      echo Waiting
      while ! grep 'Client joined' ~/.upterm/upterm.log >/dev/null; do sleep 10; done
      echo Joined
      while ! grep 'Client left' ~/.upterm/upterm.log >/dev/null; do sleep 10; done
      echo Left
    '';
  };

in
perSystem.devshell.mkShell {

  devshell.packages = [ gh-action ];

}
