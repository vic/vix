{ pkgs, inputs, ... }:
pkgs.writeShellApplication {
  name = "os-rebuild";
  text = ''
    ${inputs.self.devShells.${pkgs.system}.default}/entrypoint os-rebuild "''${@}"
  '';
}
