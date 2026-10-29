# ssh: ssh client config from the ssh-host instances, ssh-agent and the persistent vini master (linux).
{ yen, lib, ... }:
let
  # the ports served under one home (fleet `served` entries), as local forwards: local = 10000 + remote
  servedForwards =
    served: home:
    map
      (p: {
        bind.port = 10000 + p.port;
        host.address = "127.0.0.1";
        host.port = p.port;
      })
      (lib.concatMap (e: e.value) (lib.filter (e: lib.hasInfix "/home:${home.name}/" e.from.id) served));

  # ssh-host fields to upstream ssh_config directive names
  directive =
    served: h:
    {
      HostName = h.hostname;
      User = h.user;
      ProxyJump = h.proxyJump;
      ForwardAgent = h.forwardAgent;
      ControlPersist = h.controlPersist;
      ServerAliveInterval = h.serverAliveInterval;
      ServerAliveCountMax = h.serverAliveCountMax;
      SetEnv = h.setEnv;
      LocalForward =
        h.localForwards
        ++ lib.optionals (h.forwardsServedBy != null) (servedForwards served h.forwardsServedBy);
      RemoteForward = h.remoteForwards;
    }
    // h.extraOptions;
in
{
  yen.aspects.vic-ssh = {
    at = yen.aspects.vic-secrets;
    secrets = [
      yen.secret.ssh-id-ed25519
      yen.secret.ssh-conf
      yen.secret.ssh-localhost-run
    ];

    homeManager =
      {
        served ? [ ],
        ...
      }:
      {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          includes = [
            "~/.config/sops-nix/secrets/${yen.secret.ssh-conf.sopsKey}"
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
          // lib.mapAttrs (
            _: h: lib.filterAttrs (_: v: v != null && v != [ ] && v != { }) (directive served h)
          ) yen.ssh-host;
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
