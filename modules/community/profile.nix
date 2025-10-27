{ vix, ... }:
{
  vix.host-profile =
    { host }:
    {
      includes = [
        (vix.${host.name} or { })
        (vix.host-name host)
        vix.state-version
      ];
    };

  vix.user-profile =
    { host, user }@ctx:
    {
      includes = [
        (vix."${user.name}@${host.name}" or { })
        ((vix.${host.name}._.common-user-env or (_: { })) ctx)
        ((vix.${user.name}._.common-host-env or (_: { })) ctx)
      ];
    };
}
