# gitleaks: secret scanner in vic's tools, plus a flake check scanning the repo source.
{ ren, inputs, ... }:
{
  ren.aspects.gitleaks = {
    at = ren.aspects.vic-full;
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.gitleaks ];
      };
  };
  ren.aspects.gitleaks-check = {
    at = ren.system.x86_64-linux;
    checks =
      { system, ... }:
      {
        ${system.name}.gitleaks =
          system.pkgs.runCommand "gitleaks" { nativeBuildInputs = [ system.pkgs.gitleaks ]; }
            ''
              gitleaks dir --no-banner --redact ${inputs.self} && touch $out
            '';
      };
  };
}
