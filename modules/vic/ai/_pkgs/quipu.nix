# quipu built from source (flake input `quipu`). `quipu mcp` execs the companion
# `quipu-server` from its own directory, so both binaries land in $out/bin.
{
  lib,
  rustPlatform,
  src,
}:
rustPlatform.buildRustPackage {
  pname = "quipu";
  version = "0.16.0";

  inherit src;
  cargoLock.lockFile = "${src}/Cargo.lock";

  cargoBuildFlags = [
    "--bin"
    "quipu"
    "--bin"
    "quipu-server"
  ];
  buildFeatures = [
    "shacl"
    "onnx"
    "server"
  ];

  # shortcut: upstream test suite not run, add doCheck when a host needs it.
  doCheck = false;

  meta = {
    description = "Knowledge graph with SHACL validation and an MCP server";
    homepage = "https://scbrown.github.io/quipu";
    license = lib.licenses.asl20;
    mainProgram = "quipu";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
