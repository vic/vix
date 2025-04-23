{
  perSystem =
    { pkgs, ... }:
    {
      packages.vic-sops-rotate = pkgs.writeShellApplication {
        name = "vic-sops-rotate";
        text = ''
          # shellcheck disable=SC2011
          ls --zero modules/vic/secrets{.yaml,/*} | xargs -0 -n 1 sops rotate -i
        '';
      };
    };
}
