# MicroVM guests: a guest runs on a host (routed tap, host nix store shared); the host gets the microvm host module.
{
  sven,
  lib,
  inputs,
  ...
}:
let
  inherit (sven.lib) all has same;
  tap = g: "vm-${g.name}";
  guestsOf = h: lib.filterAttrs (_: g: same g.on h) sven.guest; # h: a host scope
  # the host side of its guests (gs: guest scopes): microvm host module, one routed tap each, NAT
  hostNet = gs: {
    imports = [ inputs.microvm.nixosModules.host ];
    systemd.network.enable = true; # only for the vm-* taps below
    # taps have no carrier while their guest is down; NetworkManager-wait-online covers the uplink
    systemd.network.wait-online.enable = false;
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
      }) gs
    );
    networking.nat = {
      enable = true;
      internalIPs = [ "10.0.0.0/24" ];
    };
  };
in
{
  sven.kinds.host.spawns.guest = guestsOf;

  sven.kinds.guest = {
    fields = sven.kinds.machine.fields // {
      on = sven.kinds.host;
      addr = lib.types.str; # host route 10.0.0.0/32 <-> addr/32 (microvm docs: routed-network.md)
      macAddress = lib.types.str;
    };
    spawns.user = sven.helpers.usersOf; # no spawns.guest: no guest in a guest
    sinks = {
      # its own name: the guest's nixos goes up into its host's microvm.vms
      nixos.nixos =
        { guest, nixos, ... }:
        {
          microvm.vms.${guest.name} = {
            pkgs = null; # microvm instantiates nixpkgs from the guest config, so the unfree sink applies
            nixpkgs = guest.channel.nixpkgs; # shortcut: built for the host system; set guest system when one differs
            config.imports = nixos;
          };
        };
      inherit (sven.kinds.host.sinks)
        os
        persist
        nix-features
        login-shells
        unfree
        ;
    };
  };

  sven.aspects.vm = {
    at = sven.kinds.guest;
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

  sven.aspects.vm-host = {
    at = all [
      sven.kinds.host
      (has sven.kinds.guest)
    ];
    # cycle form: ask the tree for this host's guest scopes (no second filter over sven.guest)
    cycle =
      { tree, ... }:
      {
        tree = [
          {
            category = "guests";
            children = sven.kinds.guest;
          }
        ];
        nixos = [ (hostNet (lib.concatLists (tree.select "guests"))) ]; # one answer per request: a children answer is a list
      };
  };
}
