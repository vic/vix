{ pname, pkgs, ... }:
pkgs.writeShellApplication {
  name = pname;
  runtimeInputs = [ pkgs.sops ];
  text = ''
    sops --config "$HOME"/.flake/modules/home/vic/sops.yaml --extract "[\"''${1:-hello}\"]" --decrypt "$HOME"/.flake/modules/home/vic/secrets.yaml
  '';
}
