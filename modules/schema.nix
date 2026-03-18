{ lib, ... }:
{
  den.schema.host = {
    options.iso = lib.mkEnableOption "ISO image build";
    config.iso = lib.mkDefault false;
  };

  den.schema.user = {
    config.classes = lib.mkDefault [ "homeManager" ];
  };
}
