# envs: rust tools (rust-overlay stable toolchain).
{
  ren,
  inputs,
  pkgsFor,
  ...
}:
{
  ren.aspects.env-rust = {
    at = ren.lib.and [
      ren.kinds.env
      (ren.lib.when (s: builtins.elem "rust" s.env.langs))
    ];
    env-packages =
      { system, ... }:
      let
        p = (pkgsFor system).extend (import inputs.rust-overlay);
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
