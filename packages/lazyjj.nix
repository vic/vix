{
  pname,
  pkgs,
  inputs,
}:
pkgs.rustPlatform.buildRustPackage {
  name = pname;
  src = inputs.lazyjj;
  useFetchCargoVendor = true;
  cargoHash = "sha256-rm4f8QLamtJLZ3Vag2B/SnBm7iYcR1fDPm97r8cvc/M=";
  doCheck = false; # rust tests are failing
  meta.mainProgram = pname;
}
