# enthium: the Enthium keyboard layout, on hosts that list it.
{ inputs, hostWhen, ... }:
{
  ren.aspects.enthium = {
    at = hostWhen (h: builtins.elem "enthium" h.layouts);
    nixos.services.xserver.xkb.extraLayouts.enthium = {
      description = "Enthium";
      languages = [ "eng" ];
      symbolsFile = "${inputs.enthium}/linux/usr-share-X11-xkb-symbols-us";
    };
  };
}
