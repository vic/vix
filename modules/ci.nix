{ inputs, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    let
      checkCond = name: cond: pkgs.runCommandLocal name { } (if cond then "touch $out" else "");
      vmBuilds = !pkgs.stdenvNoCC.isLinux || builtins.pathExists (self'.packages.vm + "/bin/vm");

      nargun = inputs.self.nixosConfigurations.nargun.config;
      nargunBuilds = !pkgs.stdenvNoCC.isLinux || builtins.pathExists (nargun.system.build.toplevel);
    in
    {
      checks."vm builds" = checkCond "vm-builds" vmBuilds;
      checks."nargun builds" = checkCond "nargun-builds" nargunBuilds;
    };
}
