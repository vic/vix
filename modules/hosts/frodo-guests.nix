# frodo guests: one headless claude microvm per workspace. Not trusted (no secrets); claude state + repo shared from frodo.
{ ren, ... }:
let
  inherit (ren.lib) and when same;
  names = builtins.attrNames ren.workspace;
  # shortcut: addr/MAC by sorted index, so adding a workspace can renumber others; add explicit fields when that hurts.
  guest = i: _: {
    addr = "10.0.0.${toString (i + 2)}";
    macAddress = "02:00:00:00:00:${if i + 2 < 10 then "0" else ""}${toString (i + 2)}"; # decimal digits: unique, valid hex
    on = ren.host.frodo;
    system = ren.system.x86_64-linux;
    users = [ ren.user.vic ];
    envs = [
      ren.env.nixenv
      ren.env.rustenv
    ];
  };
  vms = "/home/vic/vms";
  share = tag: source: mountPoint: {
    inherit tag source mountPoint;
    proto = "virtiofs";
  };
in
{
  ren.guest = builtins.listToAttrs (
    builtins.genList (i: {
      name = builtins.elemAt names i;
      value = guest i (builtins.elemAt names i);
    }) (builtins.length names)
  );

  ren.aspects.frodo-guests = {
    at = and [
      ren.kinds.guest
      (when (s: same s.on ren.host.frodo))
    ];
    # frodo's includes hold at every scope below frodo (Ren), guests too: drop them here.
    excludes = ren.aspects.frodo.includes;
    nixos =
      { guest, ... }:
      {
        microvm.shares = [
          (share "claude" "${vms}/${guest.name}/claude" "/home/vic/.claude")
          (share "claude-json" "${vms}/${guest.name}/claude-json" "/home/vic/.claude-json")
          (share "repo" ren.workspace.${guest.name}.repo ren.workspace.${guest.name}.repo)
        ];
        # ~/.claude.json lives in the shared dir.
        systemd.tmpfiles.rules = [
          "L+ /home/vic/.claude.json - - - - /home/vic/.claude-json/.claude.json"
        ];
      };
  };

  ren.aspects.frodo-vms = {
    at = ren.host.frodo;
    nixos.systemd.tmpfiles.rules = builtins.concatMap (w: [
      "d ${vms}/${w}/claude 0700 vic users -"
      "d ${vms}/${w}/claude-json 0700 vic users -"
    ]) names;
  };
}
