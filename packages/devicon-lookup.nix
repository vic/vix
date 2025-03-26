{
  pname,
  pkgs,
  inputs,
}:
pkgs.rustPlatform.buildRustPackage {
  name = pname;
  src = inputs.devicon-lookup;
  useFetchCargoVendor = true;
  cargoHash = "sha256-FYXInaJZhbDmE9NJKJijHfNqqaYOb5xeaZfKP4BOflE=";
}
