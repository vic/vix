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
          url = "github:oxalica/rust-overlay";
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
