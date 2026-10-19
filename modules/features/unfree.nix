# Unfree: any scope allows unfree packages by name; each machine and home config accepts what its subtree allows.
{ ren, mod, ... }:
let
  inherit (ren.lib) anyOf has;
  accept =
    { unfree, ... }:
    mod (
      { lib, ... }:
      lib.mkIf (unfree != { }) {
        nixpkgs.config.allowUnfreePredicate =
          pkg: builtins.elem (lib.getName pkg) (builtins.attrNames unfree);
      }
    );
in
{
  _module.args.allowUnfree =
    names:
    builtins.listToAttrs (
      map (name: {
        inherit name;
        value = true;
      }) names
    );

  ren.channels.unfree = {
    fold = ren.lib.fold.attrs;
    to =
      e:
      anyOf [
        e
        (has e)
      ]; # the scope itself and the machine above it
  };

  ren.aspects.unfree = {
    at = anyOf [
      ren.kinds.host
      ren.kinds.mac
      ren.kinds.user
    ];
    os = accept;
    homeManager = accept;
  };
}
