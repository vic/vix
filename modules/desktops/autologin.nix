# autologin: the display manager logs in the user a host names. The user must live on that host.
{
  yen,
  at,
  types,
  lib,
  ...
}:
{
  yen.kinds.host.fields.autologin = types.maybe yen.kinds.user;

  yen.aspects.autologin = {
    at = yen.kinds.host.where { autologin = at.exists; };
    errors =
      { host, ... }:
      lib.optional (
        !lib.any (yen.lib.same host.autologin) host.users
      ) "autologin: ${host.name} logs in ${host.autologin.name}, who has no account there";
    nixos =
      { host, ... }:
      {
        services.displayManager.autoLogin = {
          enable = true;
          user = host.autologin.name;
        };
        systemd.services."getty@tty1".enable = false;
        systemd.services."autovt@tty1".enable = false;
      };
  };
}
