{
  lib,
  stdenv,
  python3Packages,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  ast-grep,
  difftastic,
  scc,
}:
let
  pname = "headroom-ai";
  version = "0.36.5";

  wheels = {
    "x86_64-linux" = {
      platformTag = "manylinux_2_28_x86_64";
      hash = "sha256-VpVLds0QtTEgYXJedHBXVZikveP6f4D3fYKginH86ug=";
    };
    "aarch64-linux" = {
      platformTag = "manylinux_2_28_aarch64";
      hash = "sha256-N4rIbqPRiAFL6MmOWvLVtktKxq1Wa83JVxTc3wKFGTI=";
    };
    "aarch64-darwin" = {
      platformTag = "macosx_11_0_arm64";
      hash = "sha256-AZDFXwInYNSfYmjzwJcEOPm91acrwCiOJ4j/fouM5zA=";
    };
    "x86_64-darwin" = {
      platformTag = "macosx_10_12_x86_64";
      hash = "sha256-xi8Y4mGQmj3kPDIRPsdsmtZYDo+sbcgzR6cUA9ZglL8=";
    };
  };

  wheel =
    wheels.${stdenv.hostPlatform.system}
      or (throw "headroom-ai: unsupported platform ${stdenv.hostPlatform.system}");

  headroomDeps = with python3Packages; [
    tiktoken
    pydantic
    litellm
    click
    rich
    opentelemetry-api
    pyyaml
    tomlkit
    orjson
    fastapi
    uvicorn
    httpx
    h2
    openai
    mcp
    magika
    zstandard
    websockets
    onnxruntime
    transformers
    watchdog
    sqlite-vec
  ];
in
python3Packages.buildPythonPackage {
  inherit pname version;
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/cp310/h/headroom_ai/headroom_ai-${version}-cp310-abi3-${wheel.platformTag}.whl";
    inherit (wheel) hash;
  };

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  dependencies = headroomDeps;

  dontCheckRuntimeDeps = true;
  doCheck = false;

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      ast-grep
      difftastic
      scc
    ])
  ];

  meta = {
    description = "Context optimization layer for LLM applications (token-compression proxy for Claude Code)";
    homepage = "https://github.com/headroomlabs-ai/headroom";
    license = lib.licenses.asl20;
    mainProgram = "headroom";
    platforms = lib.attrNames wheels;
  };
}
