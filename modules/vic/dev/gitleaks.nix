# gitleaks: secret scanner in vic's tools, plus a flake check scanning the repo source.
{ sven, inputs, ... }:
{
  sven.aspects.gitleaks = {
    at = sven.aspects.vic-full;
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.gitleaks ];
      };
  };
  sven.aspects.gitleaks-check = {
    at = sven.system.x86_64-linux;
    checks =
      { system, ... }:
      {
        ${system.name}.gitleaks =
          system.legacyPackages.runCommand "gitleaks"
            { nativeBuildInputs = [ system.legacyPackages.gitleaks ]; }
            ''
              gitleaks dir --no-banner --redact ${inputs.self} && touch $out
            '';
      };
  };
}
