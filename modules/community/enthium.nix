# enthium: the Enthium keyboard layout, on hosts that list it.
{ inputs, ren, ... }:
{
  ren.aspects.enthium = {
    at = ren.lib.and [
      ren.kinds.host
      (ren.lib.when (s: builtins.elem "enthium" s.host.layouts))
    ];
    flake-inputs =
      { ... }:
      {
        enthium = {
          url = "github:sunaku/enthium";
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
