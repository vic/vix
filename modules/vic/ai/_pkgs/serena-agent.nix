{
  lib,
  python3Packages,
  fetchurl,
  makeWrapper,
  ast-grep,
}:
let
  pname = "serena-agent";
  version = "1.7.0";

  mslex = python3Packages.buildPythonPackage rec {
    pname = "mslex";
    version = "1.3.0";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/py3/m/mslex/mslex-${version}-py3-none-any.whl";
      hash = "sha256-xwdLNHIBs0ZvwHfFaS+86bX2KmOlH1N6U/u9Au/y7qQ=";
    };
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  sensaiUtils = python3Packages.buildPythonPackage rec {
    pname = "sensai-utils";
    version = "1.5.0";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/py3/s/sensai_utils/sensai_utils-${version}-py3-none-any.whl";
      hash = "sha256-wjxR0j01Pnqbd8cKqLp/LQqP5OZ+5bwe9Bxp26Xkvvs=";
    };
    dependencies = with python3Packages; [
      pyyaml
      requests
    ];
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };

  oslex = python3Packages.buildPythonPackage rec {
    pname = "oslex";
    version = "2.0.0";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/py3/o/oslex/oslex-${version}-py3-none-any.whl";
      hash = "sha256-8cKUQHKq/LBrbuimwBjZ67in9D188LZjC09de+RfauQ=";
    };
    dependencies = [ mslex ];
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };
in
python3Packages.buildPythonPackage {
  inherit pname version;
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/py3/s/serena_agent/serena_agent-${version}-py3-none-any.whl";
    hash = "sha256-bb8UWWcNlvsFlfhJMq3vNCYKb+FLpRNbkB/bPIx26JE=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dependencies =
    (with python3Packages; [
      anthropic
      beautifulsoup4
      cryptography
      docstring-parser
      filelock
      flask
      jinja2
      joblib
      lsprotocol
      mcp
      overrides
      pathspec
      psutil
      pydantic
      pygls
      python-dotenv
      python-multipart
      # serena/agent.py and serena/dashboard.py import webview and pystray
      # unconditionally at module scope, so the server cannot start without them even
      # when launched with --open-web-dashboard False. pystray also carries the Pillow
      # import dashboard.py makes without declaring it. The wheel names all three in
      # Requires-Dist; `dontCheckRuntimeDeps` below is why the omission built cleanly
      # and only failed at import time.
      pystray
      pywebview
      pyyaml
      regex
      requests
      ruamel-yaml
      starlette
      tiktoken
      tqdm
      urllib3
      werkzeug
    ])
    ++ [
      sensaiUtils
      oslex
      mslex
    ];

  dontCheckRuntimeDeps = true;
  doCheck = false;

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ ast-grep ])
  ];

  meta = {
    description = "Semantic code-navigation MCP tool / server";
    homepage = "https://github.com/oraios/serena";
    license = lib.licenses.mit;
    mainProgram = "serena";
  };
}
