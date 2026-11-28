# Places: base kind extended by both `machine` (`host`, `guest`, `mac`) and standalone `home`.
{
  yen,
  types,
  ...
}:
{
  yen.kinds.place.fields = {
    system = yen.kinds.system;
    channel = types.opt yen.kinds.channel yen.channel.unstable;
    trusted = types.opt types.bool false; # holds vic's secrets: the `trusted` role (roles/roles.nix)
  };
}
