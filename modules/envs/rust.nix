# envs: rust tools (rust-overlay stable toolchain).
{ sven, inputs, ... }:
{
  sven.aspects.env-rust = {
    at = sven.helpers.envHas "rust";
    flake-file.inputs.rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    env-packages =
      { env, ... }:
      let
        p = env.system.legacyPackages.extend (import inputs.rust-overlay);
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
