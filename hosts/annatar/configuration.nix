{ inputs, ... }:
{

  imports = with inputs.self.nixosModules; [
    wsl
    nix-features
    vic
    ./static.nix
  ];

  wsl.defaultUser = "vic";

}
