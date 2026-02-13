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

  vic.everywhere.includes = [
    (den.provides.unfree [ "vscode" ])
    (vix.vscode-server)
  ];

  vic.everywhere.nixos =
    { pkgs, system', ... }:
    {
      users.users.vic.packages = with pkgs; [
        vim
        vscode
        emacs-nox
        helix
        (system' inputs.antigravity).packages.default
      ];
    };
}
