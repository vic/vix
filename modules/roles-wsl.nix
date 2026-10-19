# Role wsl: a NixOS-WSL machine; vic is the default user.
{ inputs, ... }:
{
  ren.aspects.wsl.nixos = {
    imports = [ inputs.nixos-wsl.nixosModules.default ];
    wsl.enable = true;
    wsl.defaultUser = "vic";
  };
}
