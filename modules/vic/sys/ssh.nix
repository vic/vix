# ssh: ssh client config from the ssh-host instances, ssh-agent and the persistent vini master (linux).
{ ren, ... }:
{
  ren.aspects.vic-ssh = {
    at = ren.aspects.vic-secrets;
    secrets = { ... }: [
      ren.secret.ssh-id-ed25519
      ren.secret.ssh-conf
      ren.secret.ssh-localhost-run
    ];

    homeManager =
      { lib, ... }:
      let
        # ssh-host fields to upstream ssh_config directive names
        directive =
          h:
          {
            HostName = h.hostname;
            User = h.user;
            ProxyJump = h.proxyJump;
            ForwardAgent = h.forwardAgent;
            ControlPersist = h.controlPersist;
            ServerAliveInterval = h.serverAliveInterval;
            ServerAliveCountMax = h.serverAliveCountMax;
            SetEnv = h.setEnv;
            LocalForward = h.localForwards;
            RemoteForward = h.remoteForwards;
          }
          // h.extraOptions;
      in
      {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          includes = [
            "~/.config/sops-nix/secrets/ssh/sops_ssh_config"
            "~/.ssh/config.local"
          ];
          settings = {
            "*" = {
              ControlMaster = "auto";
              ControlPath = "~/.ssh/socket-%r@%h:%p";
              ControlPersist = "10m";
              AddKeysToAgent = "yes";
            };
          }
          // lib.mapAttrs (_: h: lib.filterAttrs (_: v: v != null && v != [ ] && v != { }) (directive (ren.lib.data h))) ren.ssh-host;
        };
      };

    homeLinux =
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
