# MicroVM guests: a guest runs on a host (routed tap, host nix store shared); the host gets the microvm host module.
{
  yen,
  at,
  types,
  inputs,
  ...
}:
let
  tap = g: "vm-${g.name}";
  guests.children = yen.kinds.guest;
  hostNet = gs: {
    imports = [ inputs.microvm.nixosModules.host ];
    systemd.network.enable = true;
    systemd.network.wait-online.enable = false;
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
      }) gs
    );
    networking.nat = {
      enable = true;
      internalIPs = [ "10.0.0.0/24" ];
    };
  };
in
{
  yen.kinds.host.spawns.guest = yen.lib.pointing yen.kinds.guest.fields.on yen.guest;

  yen.kinds.guest = {
    fields = {
      on = yen.kinds.host;
      addr = types.str;
      macAddress = types.str;
    };
    spawns.user = yen.helpers.usersOf;
    sinks.nixos.intoParent.nixos =
      { guest, nixos, ... }:
      {
        microvm.vms.${guest.name} = {
          pkgs = null;
          nixpkgs = guest.channel.nixpkgs;
          config.imports = nixos;
        };
      };
  };

  yen.aspects.vm = {
    at = yen.kinds.guest;
    flake-file.inputs.microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
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

  yen.aspects.vm-host = {
    at = at.all [
      yen.kinds.host
      (at.has yen.kinds.guest)
    ];
    cycle =
      { tree, ... }:
      {
        tree = [ guests ];
        nixos = hostNet (tree.select guests);
      };
  };
}
