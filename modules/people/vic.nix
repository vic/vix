# vic: identity, login shell, admin everywhere. Feature tiers vic/* gate on (module arg `vicAt`).
{ ren, inRole, ... }:
let
  inherit (ren.lib) and not within;
  headless = ren.user.vic;
  gui = and [
    headless
    (inRole ren.aspects.graphical)
  ];
in
{
  _module.args.vicAt = {
    inherit headless gui; # headless: everywhere vic lives; gui: graphical machines only
    core = headless; # alias: base.nix, community/niri-desktop.nix, vic/edit/nvim.nix and vic/** still say core/desktop
    desktop = gui;
    full = and [
      headless
      (not (within ren.aspects.installer))
    ]; # not on iso images
    secrets = and [
      headless
      (inRole ren.aspects.trusted)
    ];
  };

  ren.user.vic = {
    fullName = "Victor Borja";
    email = "vborja@apache.org";
    shell = "fish";
    admin = true;
  };
}
