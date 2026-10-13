{ lib, ... }:
{
  den.schema.user =
    { config, ... }:
    {
      config.identity = lib.mkIf (config.userName == "vic") {
        displayName = "Victor Borja";
        email = "vborja@apache.org";
      };
    };
}
