{ inputs, pkgs, ... }: (inputs.self.lib.treefmt pkgs).config.build.wrapper
