{pkgs, inputs, ...}: inputs.self.devShells.${pkgs.system}.default
