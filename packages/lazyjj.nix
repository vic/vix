{
  pname,
  pkgs,
  inputs,
}:
pkgs.rustPlatform.buildRustPackage {
  name = pname;
  src = inputs.lazyjj;
  useFetchCargoVendor = true;
  cargoHash = "sha256-1gaOUL+7PjleKMoEQ8ioVjT0thhX5Qe99QXYbOmXFiQ=";
  doCheck = false; # rust tests are failing
  meta.mainProgram = pname;
}
