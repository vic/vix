# Role wsl: a NixOS-WSL machine (form = wsl); vic is the default user.
{ inputs, hostWhen, ... }:
{
  ren.aspects.wsl = {
    at = hostWhen (h: h.form == "wsl");
    nixos = {
      imports = [ inputs.nixos-wsl.nixosModules.default ];
      wsl.enable = true;
      wsl.defaultUser = "vic";
    };
  };
}
