# vix - Vic's Nix config.

Built with [mk-darwin-system](http://github.com/vic/mk-darwin-system).

### What it does.

This flake builds my darwin system: 

system packages (oeiuwq), user packages (vic), development environments for different langs (pkgSets), and some configurations (dotfiles).
### Activation

Activate system with `env NIX_CONF_DIR="$PWD" nix run`.

### Searching for packages 

`nix search --inputs-from . nixpkgs keybase`

### Structure

```
default.nix            - Setups the environment for loading modules using mkDarwinSystem.
lib                    - Source for vix-lib. Functions used by modules.
modules/
  pkg-overrides.nix    - Custom packages and some overloading.
  pkg-sets.nix         - Bags of packages, mainly used for different development environments.
  oeiuwq               - System level module. Configures system wide options and packages.
  vic                  - Vic's home environment.
```

### Additional output

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
$HOME/Applications/Home Manager Apps/XXX.app    - A link to some apps installed using derivations.

```

