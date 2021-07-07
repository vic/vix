{ nixpkgs, self, ... }:
{ pkgs, lib, ... }: {

  shellEnv = name: shell:
    with lib;
    let
      drv = pkgs.runCommand "${name}-shell-env" { } ''
              set -x
              declare -x OUTER_PATH="$PATH"
              declare -x outer="$out"
              mkdir -p $outer/out

              function clear_some_env() {
                grep -v \
                -e "declare -x HOME" \
                -e "declare -x NIX_BUILD_TOP" \
                -e "declare -x OLDPWD" \
                -e "declare -x PATH" \
                -e "declare -x PWD" \
                -e "declare -x SHELL" \
                -e "declare -x TEMP" \
                -e "declare -x TMPDIR" \
                -e "declare -x TMP"
              }

              cat <<EOF > $outer/input-derivation
                source ${shell.inputDerivation}
                declare -x nobuildPhase=true
                \$_derivation_original_builder -x \$_derivation_original_args
                PATH="$OUTER_PATH" cp $NIX_BUILD_TOP/env-vars $outer/env-vars
        EOF

               env -i bash --noprofile --norc -x $outer/input-derivation
        	'';
    in builtins.toPath drv;

}
