{ lib, ... }:
{
  den.schema.host = {
    options.iso = lib.mkEnableOption "ISO image build";
    config.iso = lib.mkDefault false;
  };

  den.schema.user = {
    config.classes = lib.mkDefault [ "homeManager" ];

    # shape borrowed from sini: one typed identity per user (git, jj, ssh read it)
    options.identity = {
      displayName = lib.mkOption { type = lib.types.str; };
      email = lib.mkOption { type = lib.types.str; };
      gpgKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
    options.sshKeys = lib.mkOption {
      default = [ ];
      type = lib.types.listOf (
        lib.types.submodule {
          options.tag = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
          options.key = lib.mkOption { type = lib.types.str; };
        }
      );
    };
  };
}
