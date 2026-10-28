# vic's feature tiers: vic/* features gate on them (`at = sven.aspects.vic-<tier>`).
{ sven, ... }:
let
  inherit (sven.lib) all not within;
in
{
  sven.aspects.vic-headless.at = sven.user.vic; # everywhere vic lives
  sven.aspects.vic-gui.at = all [
    sven.aspects.vic-headless
    sven.aspects.on-graphical
  ]; # graphical machines only
  sven.aspects.vic-full.at = all [
    sven.aspects.vic-headless
    (not (within sven.aspects.installer))
  ]; # not on iso images
  sven.aspects.vic-secrets.at = all [
    sven.aspects.vic-headless
    sven.aspects.on-trusted
  ]; # trusted machines; also the sops consumer (vic/sys/secrets.nix)
}
