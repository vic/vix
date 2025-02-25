{ pkgs, inputs, ... }: (inputs.self.lib.treefmt pkgs).config.build.check inputs.self
