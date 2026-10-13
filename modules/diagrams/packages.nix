# Assembles every entry into flake packages and the write-diagrams app.
{
  perSystem =
    {
      pkgs,
      diagram,
      hostEntries,
      userEntries,
      homeEntries,
      fleetEntries,
      hostTextEntries,
      galleries,
      readmeDrv,
      ...
    }:
    let
      everyEntry = hostEntries ++ userEntries ++ homeEntries ++ fleetEntries ++ hostTextEntries;
    in
    {
      _module.args.everyEntry = everyEntry;

      packages = diagram.export.entriesToPackages everyEntry // {
        write-diagrams = diagram.export.mkWriteScript pkgs {
          entries = everyEntry;
          inherit galleries readmeDrv;
          destExpr = ''"$(${pkgs.git}/bin/git rev-parse --show-toplevel)/diagrams"'';
        };
      };
    };
}
