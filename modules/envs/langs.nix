# envs: ref-typed `yen.kinds.lang` and tools for each language (zero string enums!).
{
  yen,
  types,
  inputs,
  ...
}:
let
  tools = {
    c = p: [
      p.gcc
      p.gnumake
      p.pkg-config
    ];
    go = p: [
      p.go
      p.gopls
    ];
    nix = p: [
      p.nixd
      p.nixfmt
      p.nil
      p.npins
      p.nix-unit
      p.nh
      p.cachix
      p.just
      p.statix
      p.deadnix
    ];
    node = p: [
      p.nodejs
      p.pnpm
      p.yarn
      p.bun
      p.typescript
    ];
    python = p: [
      p.python3
      p.uv
    ];
    rust =
      p:
      (r: [
        (r.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
            "clippy"
            "rustfmt"
          ];
        })
        r.bacon
        r.wasm-pack
        r.wasm-bindgen-cli
      ])
        (p.extend (import inputs.rust-overlay));
  };
  inputsOf.rust.rust-overlay = {
    url = "github:oxalica/rust-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  langNames = builtins.attrNames tools;
in
{
  yen.kinds.lang = { };
  yen.lang = {
    c = { };
    go = { };
    nix = { };
    node = { };
    python = { };
    rust = { };
  };

  yen.kinds.env.fields.langs = types.listOf yen.kinds.lang;
  yen.aspects = builtins.listToAttrs (
    map (lang: {
      name = "env-${lang}";
      value = {
        at = yen.helpers.envHas yen.lang.${lang};
        env-packages = { env, ... }: tools.${lang} env.system.legacyPackages;
      }
      // (if inputsOf ? ${lang} then { flake-file.inputs = inputsOf.${lang}; } else { });
    }) langNames
  );
}
