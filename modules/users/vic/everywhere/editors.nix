{
  den,
  vix,
  inputs,
  ...
}:
{
  flake-file.inputs.antigravity = {
    url = "github:jacopone/antigravity-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.inputs.neomacs = {
    url = "github:eval-exec/neomacs";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  vic.everywhere.includes = [
    (vix.vscode-server)
  ];

  vic.everywhere.user =
    { pkgs, system', ... }:
    {
      packages = with pkgs; [
        vim
        vscode
        emacs-nox
        helix
        (system' inputs.antigravity).packages.default
        (system' inputs.neomacs).packages.default
      ];
    };
}
