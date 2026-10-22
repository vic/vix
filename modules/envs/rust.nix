# envs: rust tools (rust-overlay stable toolchain).
{
  ren,
  inputs,
  ...
}:
{
  ren.aspects.env-rust = {
    at = ren.lib.and [
      ren.kinds.env
      (ren.lib.when (s: builtins.elem "rust" s.env.langs))
    ];
    flake-inputs =
      { ... }:
      {
        rust-overlay = {
          url = "github:oxalica/rust-overlay/3100cf6ff140fb298f09192de610f4037d3bab0f";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    env-packages =
      { system, ... }:
      let
        p = system.legacyPackages.extend (import inputs.rust-overlay);
      in
      [
        (p.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
            "clippy"
            "rustfmt"
          ];
        })
        p.wasm-pack
        p.wasm-bindgen-cli
      ];
  };
}
