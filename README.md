# vix - Vic's Nix config.

This flake builds my darwin system: 

system packages (oeiuwq), user packages (vic), development environments for different langs (pkgSets), and some configurations (eg, doom-emacs files).

Built with the following libraries (and lots of wonderful nix packages and libs):

- [mk-darwin-system](http://github.com/vic/mk-darwin-system) Extracted from vix. 

### Activation

Activate system with `env NIX_CONF_DIR="$PWD" nix run` the first time, and if you are vic, use `vix-activate` fish function from anywhere once activated.

### Searching for packages 

`nix search --inputs-from . nixpkgs keybase` or use the `vix-nixpkg-search` fish function (see bellow).

### Structure

```
vix/
  default.nix            - Setups the environment for loading modules using mkDarwinSystem.
  lib                    - Source for vix-lib. Functions used by modules.
  modules/
    pkg-overrides.nix    - Custom packages and some overloading.
    pkg-sets.nix         - Bags of packages, mainly used for different development environments.
    oeiuwq               - System level module. Configures system wide options and packages.
    vic                  - Vic's home environment.
```

### Vic's HOME Additional output

Particularly for my `vic` user, upon activation this flake creates the following symlinks:

```

$HOME/.nix-out/nixpkgs          - A reference to the nixpkgs source used to build the system.
                                  Useful for grepping and finding nix libs/packages on it.
$HOME/.nix-out/nix-darwin       - Idem, useful for grepping for options and other stuff.
$HOME/.nix-out/home-manager     - Idem, useful for grepping for options and other stuff.

$HOME/.nix-out/openjdk          - A link to the nix store jvm. useful for telling IDEs about what JVM to use.

$HOME/.nix-out/vix              - A refrence to the vix source snapshot used to build the system.
                                  Useful for pointing shell.nix files to it, and let lorri re-use packages from system.

$HOME/.nix-out/dots             - A link to vic's secret configuration stuff such as private keys and passwords.

$HOME/.nix-out/direnv           - A collection of shell scripts intended to be sourced by direnv in order to
                                  provide environments for different languages (see pkg-sets.nix)


/Library/Java/JavaVirtualMachines/XXX           - Links vic's selected JVM system wide for MacOS.
$HOME/Applications/Home Manager Applications/XXX.app    - A link to some apps installed using derivations.

```


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
