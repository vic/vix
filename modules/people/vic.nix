# vic: identity, login shell, admin everywhere. Feature tiers vic/* gate on (module arg `vicAt`).
{ ren, ... }:
let
  inherit (ren.lib) and not within;
  core = ren.user.vic;
in
{
  _module.args.vicAt = {
    inherit core; # everywhere vic lives
    full = and [
      core
      (not (within ren.aspects.installer))
    ]; # not on iso images
    desktop = and [
      core
      (within ren.aspects.graphical)
    ];
    secrets = and [
      core
      (within ren.aspects.trusted)
    ];
  };

  ren.user.vic = {
    fullName = "Victor Borja";
    email = "vborja@apache.org";
    shell = "fish";
    admin = true;
  };
}
