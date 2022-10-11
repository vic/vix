## Test your system is buildable.

``` sh
nix flake check
```

## Activate your system

``` sh
nix run
```

## Interactive shell

Your flake includes a development shell which includes tools
like `niv` (for dependency management), `alejandra` (nix code formatter).

``` sh
nix develop
```

## Add home-managed nixpkgs applications.

Edit `nix/homeConfigurations/your-username.nix` and add
the desired values for `home.programs`, for example, if
you like to use [exa](https://the.exa.website/):

``` nix
home.programs = with pkgs; [ exa ];
```


## Install home-managed dmg applications (sourced by Niv)

Your flake can use [niv](https://github.com/nmattia/niv) to declare
external source dependencies, like `.dmg` applications distributed via
github releases or for MacOS apps not available via `nixpkgs`.

See `niv --help` and the [niv homepage](https://github.com/nmattia/niv) for
more instructions on adding, updating and removing dependencies.

Suppose we would like to install [Keytty](https://keytty.com/). 
First, we need to determine the `.dmg` url from [keytty's releases](https://github.com/keytty/shelter/releases) page.
And then add a dependency using `niv`.

``` sh
niv add keytty-dmg -t 'https://github.com/keytty/shelter/releases/download/<version>/Keytty.<version>.dmg' -v '1.2.8'
```

After adding the `keytty-dmg` dependency at version `1.2.8`, we can install it
by editing `nix/homeConfigurations/your-username.nix`:

``` nix
home.appsFromDmg = [ "keytty-dmg "] # NOTE: same name as niv-managed dependency.
```
