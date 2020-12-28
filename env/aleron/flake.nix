{
  description = "Aleron Nix environment";

  inputs = {
    vix.url = "path:../..";
    nixpkgs.follows = "vix/nixpkgs";
    flake-utils.follows = "vix/flake-utils";
  };

  outputs = { self, vix, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem vix.systems (system:
    let
      pkgs = vix.pkgs.${system};
    in {
      devShell = with pkgs;
        mkShell {
          buildInputs = [
	    gping
	    bat
	    xsv
	    broot
	    htop
	    shfmt
	    shellcheck
	    ripgrep
            jq
	    fd
	    tig
	    exa
            fzf
            coursier
            dbmate
            emacsMacport
            fish
            gettext
            git-lfs
            kubernetes-helm
            mill
            nodejs
            google-cloud-sdk
            jdk
            kubectl
            # coursierPackages.graalvm
            postgresql
            metals
	    gitAndTools.delta
	    gitui
	    k9s
	    hyperfine
          ];

          shellHook = ''
            echo Welcome to Aleron
          '';
        };
    }
  );
}
