# vic-tools: the Rust hot path (`vic statusline`, `vic hook guard|ledger|boot`) from ./tools.
{ yen, ... }:
{
  yen.aspects.vic-tools = {
    at = yen.kinds.system;
    packages =
      { system, ... }:
      let
        pkgs = system.legacyPackages;
      in
      {
        vic-tools = pkgs.rustPlatform.buildRustPackage {
          pname = "vic-tools";
          version = "0.1.0";
          src = ../../tools;
          cargoLock.lockFile = ../../tools/Cargo.lock;
          meta.mainProgram = "vic";
        };
      };
  };
}
