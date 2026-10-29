# vic's feature tiers: vic/* features gate on them (`at = yen.aspects.vic-<tier>`).
{ yen, ... }:
let
  inherit (yen.lib) all not within;
in
{
  yen.aspects.vic-headless.at = yen.user.vic; # everywhere vic lives
  yen.aspects.vic-gui.at = all [
    yen.aspects.vic-headless
    yen.aspects.on-graphical
  ]; # graphical machines only
  yen.aspects.vic-full.at = all [
    yen.aspects.vic-headless
    (not (within yen.aspects.installer))
  ]; # not on iso images
  yen.aspects.vic-secrets.at = all [
    yen.aspects.vic-headless
    yen.aspects.on-trusted
  ]; # trusted machines; also the sops consumer (vic/sys/secrets.nix)
}
