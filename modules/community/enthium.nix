# enthium: the Enthium keyboard layout, on hosts that list it.
{ inputs, hostWhen, ... }:
{
  ren.aspects.enthium = {
    at = hostWhen (h: builtins.elem "enthium" h.layouts);
    flake-inputs =
      { ... }:
      {
        enthium = {
          url = "github:sunaku/enthium/832ac5562b00e2b0776e5268b04c19ebe0eabfb7";
          flake = false;
        };
      };
    nixos.services.xserver.xkb.extraLayouts.enthium = {
      description = "Enthium";
      languages = [ "eng" ];
      symbolsFile = "${inputs.enthium}/linux/usr-share-X11-xkb-symbols-us";
    };
  };
}
