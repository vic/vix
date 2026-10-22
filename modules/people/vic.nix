# vic: identity, login shell, admin everywhere. Feature tiers vic/* gate on (`at = ren.aspects.vic-<tier>`).
{ ren, ... }:
let
  inherit (ren.lib) and not within;
in
{
  ren.aspects.vic-headless.at = ren.user.vic; # everywhere vic lives
  ren.aspects.vic-gui.at = and [
    ren.aspects.vic-headless
    ren.aspects.on-graphical
  ]; # graphical machines only
  ren.aspects.vic-full.at = and [
    ren.aspects.vic-headless
    (not (within ren.aspects.installer))
  ]; # not on iso images
  ren.aspects.vic-secrets.at = and [
    ren.aspects.vic-headless
    ren.aspects.on-trusted
  ]; # trusted machines; also the sops consumer (vic/sys/secrets.nix)

  ren.user.vic = {
    fullName = "Victor Borja";
    email = "vborja@apache.org";
    shell = "fish";
    admin = true;
  };
}
