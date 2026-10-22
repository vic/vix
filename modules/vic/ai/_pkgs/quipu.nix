# Prebuilt quipu release. `quipu mcp` execs the companion `quipu-server` from its
# own directory, so both binaries must stay side by side in $out/bin.
{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
}:
let
  version = "0.12.1";

  # shortcut: no x86_64-darwin target, add it when a host needs it.
  targets = {
    "aarch64-darwin" = {
      triple = "aarch64-apple-darwin";
      hash = "sha256-CaYvpEZ5CpkTFwhhmlLfV4nGK7jlKvLQRTGbJFoZHJk=";
    };
    "x86_64-linux" = {
      triple = "x86_64-unknown-linux-gnu";
      hash = "sha256-+8z/ewiI/VA1JZcerkfYN9eofeVRyCVMShI0ZWYu0zI=";
    };
    "aarch64-linux" = {
      triple = "aarch64-unknown-linux-gnu";
      hash = "sha256-6ZPTG7WmkZU/YtO065hxBCi9iPE0/7zdGQCXAMkNBIo=";
    };
  };

  target =
    targets.${stdenv.hostPlatform.system}
      or (throw "quipu: unsupported platform ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "quipu";
  inherit version;

  src = fetchzip {
    url = "https://github.com/scbrown/quipu/releases/download/quipu-ai-v${version}/quipu-quipu-ai-v${version}-${target.triple}.tar.gz";
    inherit (target) hash;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin quipu quipu-server
    runHook postInstall
  '';

  meta = {
    description = "Knowledge graph with SHACL validation and an MCP server";
    homepage = "https://scbrown.github.io/quipu";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "quipu";
    platforms = lib.attrNames targets;
  };
}
