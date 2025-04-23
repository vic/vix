{
  lib,
  inputs,
  ...
}:
{
  jj-git-init.description = "init jj to follow git branch";
  jj-git-init.argumentNames = [ "branch" ];
  jj-git-init.body = ''
    jj git init --colocate
    jj bookmark track "$branch@origin"
    jj config set --repo "revset-aliases.'trunk()'" "$branch@origin"
  '';

  jj-desc.body = ''
    jj describe --edit -m "$(echo -e "\n")$(jj status --color never | awk '{print "JJ: " $0}')$(echo -e "\n")$(jj show --git --color never  | awk '{print "JJ: " $0}')"
  '';

  mg.body = "spc u SPC gg -r \"$PWD\" RET";
  spc.body = "SPC $argv -- -nw";
  vspc.body = "SPC $argv -- -c";
  fish_hybrid_key_bindings.description = "Vi-style bindings that inherit emacs-style bindings in all modes";
  fish_hybrid_key_bindings.body = ''
    for mode in default insert visual
        fish_default_key_bindings -M $mode
    end
    fish_vi_key_bindings --no-erase
  '';
  vix-activate.description = "Activate a new vix system generation";
  vix-activate.body = "nix run /hk/vix";
  vix-shell.description = "Run nix shell with vix's nixpkgs";
  vix-shell.body = "nix shell --inputs-from $HOME/.nix-out/nixpkgs";
  vix-nixpkg-search.description = "Nix search on vix's nixpkgs input";
  vix-nixpkg-search.body = "nix search --inputs-from $HOME/.nix-out/vix nixpkgs $argv";
  rg-vix-inputs.description = "Search on vix flake inputs";
  rg-vix-inputs.body =
    let
      maybeFlakePaths = f: if builtins.hasAttr "inputs" f then flakePaths f else [ ];
      flakePaths =
        flake: [ flake.outPath ] ++ lib.flatten (lib.mapAttrsToList (_: maybeFlakePaths) flake.inputs);
      paths = builtins.concatStringsSep " " (flakePaths inputs.self);
    in
    "rg $argv ${paths}";
  rg-vix.description = "Search on current vix";
  rg-vix.body = "rg $argv $HOME/.nix-out/vix";
  rg-nixpkgs.description = "Search on current nixpkgs";
  rg-nixpkgs.body = "rg $argv $HOME/.nix-out/nixpkgs";
  rg-home-manager.description = "Search on current home-manager";
  rg-home-manager.body = "rg $argv $HOME/.nix-out/home-manager";
  rg-nix-darwin.description = "Search on current nix-darwin";
  rg-nix-darwin.body = "rg $argv $HOME/.nix-out/nix-darwin";
  nixos-opt.description = "Open a browser on search.nixos.org for options";
  nixos-opt.body = ''open "https://search.nixos.org/options?sort=relevance&query=$argv"'';
  nixos-pkg.description = "Open a browser on search.nixos.org for packages";
  nixos-pkg.body = ''open "https://search.nixos.org/packages?sort=relevance&query=$argv"'';
  repology-nixpkgs.description = "Open a browser on search for nixpkgs on repology.org";
  repology-nixpkgs.body = ''open "https://repology.org/projects/?inrepo=nix_unstable&search=$argv"'';
}
