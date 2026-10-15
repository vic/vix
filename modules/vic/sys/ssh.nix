{ ... }:
{
  vic.ssh = {

    homeManager = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        includes = [
          "~/.config/sops-nix/secrets/ssh/sops_ssh_config"
          "~/.ssh/config.local"
        ];
        matchBlocks = {
          "*" = {
            controlMaster = "auto";
            controlPath = "~/.ssh/socket-%r@%h:%p";
            controlPersist = "10m";
            addKeysToAgent = "yes";
          };
          "edge" = {
            host = "edge";
            hostname = "192.168.192.168";
          };
          "vini" = {
            hostname = "bitstream.ts.json64.dev";
            user = "vic";
            proxyJump = "vic@vpn.json64.dev";
            forwardAgent = true;
            controlPersist = "no";
          };
          # Same host, user and controlPath as vini: the vini-ssh master opens these forwards
          # and every later `ssh vini` reuses it. Ports: local = 10000 + remote.
          "vini-tunnel" = {
            hostname = "bitstream.ts.json64.dev";
            user = "vic";
            proxyJump = "vic@vpn.json64.dev";
            forwardAgent = true;
            controlPersist = "no";
            localForwards =
              map
                (port: {
                  bind.port = 10000 + port;
                  host.address = "127.0.0.1";
                  host.port = port;
                })
                [
                  8080 # agentsview
                  8787 # headroom dashboard
                  8001 # sqlite-web omni.db
                ];
          };
          "sini" = {
            hostname = "bitstream.ts.json64.dev";
            user = "sini";
            proxyJump = "vic@vpn.json64.dev";
            forwardAgent = true;
            controlPersist = "no";
          };
          "uptermd.upterm.dev" = {
            forwardAgent = true;
            serverAliveInterval = 10;
            serverAliveCountMax = 6;
            extraOptions.ControlPath = "~/.ssh/upterm-%C";
            setEnv.TERM = "xterm-256color";
            localForwards = [
              {
                bind.port = 8000;
                host.address = "127.0.0.1";
                host.port = 8000;
              }
              {
                bind.port = 5900;
                host.address = "127.0.0.1";
                host.port = 5900;
              }
            ];
            remoteForwards = [
              {
                bind.port = 5000;
                host.address = "127.0.0.1";
                host.port = 5000;
              }
            ];
          };
        };
      };
    };

    hmLinux =
      { config, pkgs, ... }:
      {
        services.ssh-agent.enable = true;

        # Keeps one ssh master to vini open; every `ssh vini` reuses it through controlPath.
        systemd.user.services.vini-ssh = {
          Unit = {
            Description = "persistent ssh master connection to vini";
            After = [ "ssh-agent.service" ];
            # retry forever: the agent is empty until the key is unlocked after login.
            StartLimitIntervalSec = 0;
          };
          Service = {
            Environment = "SSH_AUTH_SOCK=%t/${config.services.ssh-agent.socket}";
            ExecStart = "${pkgs.openssh}/bin/ssh -N -o BatchMode=yes -o ControlMaster=yes -o ControlPersist=no -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes vini-tunnel";
            Restart = "always";
            RestartSec = 10;
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
  };
}
