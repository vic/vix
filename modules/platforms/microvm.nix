# MicroVM guests: a guest runs on a host (routed tap, host nix store shared); the host gets the microvm host module.
{
  ren,
  lib,
  inputs,
  ...
}:
let
  vix = ren.helpers;
  inherit (ren.lib) and has;
  tap = g: "vm-${g.name}";
  guestsOf = h: lib.filterAttrs (_: g: ren.lib.same g.on h) ren.guest; # h: a host instance
in
{
  # hosts run guests (merges with the host kind in platforms/nixos.nix, v33)
  ren.kinds.host.below = [ ren.kinds.guest ];
  ren.kinds.host.spawns.guest = s: guestsOf s.host;

  ren.kinds.guest = {
    is = ren.kinds.host; # declares its own `below`: no guest in a guest
    below = [ ren.kinds.user ];
    spawns.user = s: vix.usersOf s.guest;
    on = ren.kinds.host;
    addr = lib.types.str; # host route 10.0.0.0/32 <-> addr/32 (microvm docs: routed-network.md)
    macAddress = lib.types.str;
  };

  ren.aspects.vm = {
    at = ren.kinds.guest;
    flake-inputs =
      { ... }:
      {
        microvm.url = "github:microvm-nix/microvm.nix";
        microvm.inputs.nixpkgs.follows = "nixpkgs";
      };
    nixos =
      { guest, ... }:
      {
        imports = [ inputs.microvm.nixosModules.microvm ];
        microvm.hypervisor = "qemu";
        microvm.vcpu = 2;
        microvm.mem = 4096;
        microvm.shares = [
          {
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            tag = "ro-store";
            readOnly = true;
            proto = "virtiofs";
          }
        ];
        microvm.interfaces = [
          {
            type = "tap";
            id = tap guest;
            mac = guest.macAddress;
          }
        ];
        networking.useNetworkd = true;
        systemd.network.networks."10-eth" = {
          matchConfig.MACAddress = guest.macAddress;
          address = [ "${guest.addr}/32" ];
          routes = [
            { Destination = "10.0.0.0/32"; }
            {
              Gateway = "10.0.0.0";
              GatewayOnLink = true;
            }
          ];
          networkConfig.DNS = [ "1.1.1.1" ];
        };
      };
  };

  ren.aspects.vm-host = {
    at = and [
      ren.aspects.metal
      (has ren.kinds.guest)
    ];
    nixos =
      { host, ... }:
      {
        imports = [ inputs.microvm.nixosModules.host ];
        systemd.network.enable = true; # only for the vm-* taps below
        # keep the host DNS stack as it was (NetworkManager + resolvconf): networkd would switch it to resolved
        services.resolved.enable = false;
        networking.networkmanager.unmanaged = [ "interface-name:vm-*" ];
        systemd.network.networks = builtins.listToAttrs (
          map (g: {
            name = "30-${tap g}";
            value = {
              matchConfig.Name = tap g;
              address = [ "10.0.0.0/32" ];
              routes = [ { Destination = "${g.addr}/32"; } ];
              networkConfig.IPv4Forwarding = true;
            };
          }) (builtins.attrValues (guestsOf host))
        );
        networking.nat = {
          enable = true;
          internalIPs = [ "10.0.0.0/24" ];
        };
      };
  };
}
