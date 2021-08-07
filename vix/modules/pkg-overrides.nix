{ config, pkgs, lib, vix-lib, ... }: {
  nixpkgs.overlays = [
    (self: super: {

      # See https://github.com/NixOS/nixpkgs/pull/129543/files
      neovim = super.neovim-unwrapped;

      leader = vix-lib.nivGoAutoMod "leader";

      xbarApp = vix-lib.nivApp "xbar";

      VimMotionApp = vix-lib.nivApp "VimMotion";

      HamerspoonApp = vix-lib.nivApp "Hamerspoon";

      KeyttyApp = vix-lib.nivApp "Keytty";

      IdeaApp = vix-lib.nivApp "Idea";

      EmacsApp = (vix-lib.nivApp "Emacs").overrideAttrs (old:
        let
          bin_dir = {
            "aarch64-darwin" = "bin-arm64-*/";
          }.${config.nixpkgs.system} or "bin-x86_64-*/";
        in {
          installPhase = ''
            ${old.installPhase}
            mkdir -p $out/bin
            ln -s $out/Applications/Emacs.app/Contents/Resources/{etc,man,info} $out/
            ln -s $out/Applications/Emacs.app/Contents/MacOS/${bin_dir} $out/bin
            ln -s $out/Applications/Emacs.app/Contents/MacOS/Emacs $out/bin/emacs
          '';
        });

    })
  ];
}
