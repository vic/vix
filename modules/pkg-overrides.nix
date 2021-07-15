{ pkgs, lib, vix-lib, ... }: {
  nixpkgs.overlays = [
    (self: super: {
      vix-dots = vix-lib.mkOutOfStoreSymlink "/hk/dots";

      # See https://github.com/NixOS/nixpkgs/pull/129543/files
      neovim = super.neovim-unwrapped;

    })
  ];
}
