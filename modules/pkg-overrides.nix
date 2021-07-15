{ pkgs, lib, vix-lib, ... }: {
  nixpkgs.overlays = [
    (self: super: {

      # See https://github.com/NixOS/nixpkgs/pull/129543/files
      neovim = super.neovim-unwrapped;

    })
  ];
}
