{
  flake.modules.homeManager.vic =
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
        controlPath = "~/.ssh/%r@%h:%p";
        controlPersist = "10m";
        includes = [ "~/.config/sops-nix/secrets/ssh/sops_ssh_config" ];

        matchBlocks = {
          "github.com" = {
            identityFile = "~/.ssh/id_ed25519";
            extraOptions.ControlPersist = "no";
          };

          "uptermd.upterm.dev" = {
            forwardAgent = true;
            serverAliveInterval = 10;
            serverAliveCountMax = 6;
            extraOptions.ControlPath = "~/.ssh/upterm-%C";
            setEnv.TERM = "xterm-256color";
            localForwards = [
              {
                bind.port = 8000; # http
                host.address = "127.0.0.1";
                host.port = 8000;
              }
              {
                bind.port = 5900; # vnc
                host.address = "127.0.0.1";
                host.port = 5900;
              }
            ];
            remoteForwards = [
              {
                bind.port = 5000; # sops
                host.address = "127.0.0.1";
                host.port = 5000;
              }
            ];
          };

        };
      };

      services.ssh-agent.enable = pkgs.stdenv.isLinux;

      home.activation.link-ssh-id = lib.hm.dag.entryAfter [ "link-flake" "sops-nix" "reloadSystemd" ] ''
        run ln -sf "${config.sops.secrets."ssh/id_ed25519".path}" $HOME/.ssh/id_ed25519
      '';
    };
}
