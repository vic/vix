{
  perSystem =
    { pkgs, ... }:
    let
      vic-sops-get = pkgs.writeShellApplication {
        name = "vic-sops-get";
        text = ''
          export PATH="${
            pkgs.lib.makeBinPath [
              pkgs.sops
              pkgs.ssh-to-age
            ]
          }:$PATH"
          declare -a args more

          file=""
          dry=""
          extract=""
          server=""
          setup=""

          while test -n "''${1:-}"; do
            first="$1"
            shift
            case "$first" in
              "--setup")
                setup="$1"
                shift
              ;;
              "--dry-run")
                dry="true"
              ;;
              "-f" | "--file")
                file="${./..}/vic/secrets/$1"
                shift
              ;;
              "-a" | "--attr")
                file="${./..}/vic/secrets.yaml"
                extract="[\"$1\"]"
                shift
              ;;
              "-s" | "--keyservice")
                server="$1"
                shift
              ;;
              *)
                more+=("$first")
              ;;
            esac
          done

          if test -n "$extract"; then
            args+=("--extract" "$extract")
          fi

          if test -n "$server"; then
            args+=("--enable-local-service=false" "--keyservice" "$server")
          fi

          args+=("''${more[@]}")

          if test -n "$file"; then
            args+=("$file")
          fi

          function perform_setup() {
            echo -n "Password: " >&2
            local pass
            read -r -s pass
            sops decrypt "''${args[@]}" | SSH_TO_AGE_PASSPHRASE="$pass" ssh-to-age -private-key -o "$setup" 2>/dev/null
          }

          if test -n "$dry"; then
            echo "sops decrypt" "''${args[@]}"
            exit 0
          elif test -n "$setup"; then
            perform_setup
          else
            exec sops decrypt "''${args[@]}"
          fi
        '';
      };
    in
    {
      packages.vic-sops-get = vic-sops-get;
    };
}
