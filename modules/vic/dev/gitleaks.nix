# gitleaks: secret scanner in vic's tools, plus a flake check scanning the repo source.
{ yen, inputs, ... }:
{
  yen.aspects.gitleaks = {
    at = yen.aspects.vic-full;
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.gitleaks ];
      };
  };
  yen.aspects.gitleaks-check = {
    at = yen.system.x86_64-linux;
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
