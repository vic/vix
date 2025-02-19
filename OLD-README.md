# vix - Vic's Nix config.

This flake builds my darwin system: 

Built with the following libraries (and lots of wonderful nix packages and libs):

- [mk-darwin-system](http://github.com/vic/mk-darwin-system) Extracted from vix. 

### Activation

Activate system with `env NIX_CONF_DIR="$PWD" nix run` the first time.

### Searching for packages 

`nix search --inputs-from . nixpkgs keybase` or use the `vix-nixpkg-search` fish function (see bellow).

### Vic's Fish environment

Enabled fzf integration for fast searching History (CTRL+R) and files (CTRL+T)

Enabled direnv integration for switching development environments upon entering dirs.

Fish history is linked from private keybase repository where it is backed up.

Appart from some [command aliases](vix/modules/vic/fish/default.nix), the following fish functions are handy:

```
vix-activate             - Activate a new system generation, can be called from anywhere.

vix-nixpkg-search        - Same as:
                           nix search --inputs-from $HOME/.nix-out/vix nixpkgs $argv

rg-vix-inputs PATTERM    - Search using rg on vix flake inputs recursively.
                           This one is handy for grepping for nix code, options, packages, libs.

rg-vix PATTERN           - Search using rg on current system vix
rg-nixpkgs PATTERN       - Search using rg on current system nixpkgs
rg-home-manager PATTERN  - Search using rg on current system home-manager
rg-nix-darwin PATTERN    - Search using rg on current system nix-darwin

nixos-opt OPTION         - Search on nixos.org for OPTION
nixos-pkg PACKAGE        - Search on nixos.org for PACKAGE

repology-nixpkgs PACKAGE - Search for PACKAGE using repology.org
```
