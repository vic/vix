{ config
, pkgs
, lib
, USER
, HOME
, direnv_dir
, ...
}:
lib.mkMerge
  [
    {
      home-manager.users.${ USER }.home.file = {
        ".config/direnv/lib/use_flake.sh".text =
          ''
          function use_flake() {
            local flake flake5
            flake="''${1:-"$PWD"}"
            flake5="$(echo "$flake" | md5)"

            cat <<EOF > ${ HOME }/.direnv/$flake5-shell.nix
              (getFlake "$flake").devShell.''${currentSystem}
          EOF
            eval "$(${ pkgs.lorri }/bin/lorri direnv --shell-file ${ HOME }/.direnv/$flake5-shell.nix)"
          }
          '';
        ".config/direnv/lib/use_vix.sh".text =
          ''
          function use_vix() {
            source ~/"${ direnv_dir }/$1.sh"
          }
          '';
      };
    }
    #,
    {
      home-manager.users.${ USER }.home.file =
        lib.mkMerge
          (
            map
              (
                shellName:
                {
                  "${ direnv_dir }/${ shellName }.sh".text =
                    ''
                    eval "$(${ pkgs.lorri }/bin/lorri direnv --shell-file ${ HOME }/${ direnv_dir }/${ shellName }.nix)"'';
                  "${ direnv_dir }/${ shellName }.nix".text =
                    ''
                    (builtins.getFlake "${ HOME }/.nix-out/vix").packages.''${builtins.currentSystem}.pkgShells.${ shellName }'';
                }
              )
              ( lib.attrNames config.pkgSets )
          );
    }
  ]
