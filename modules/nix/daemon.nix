# nix-daemon: builds live in a memory-capped slice and die first under pressure; gc runs idle.
{ yen, ... }:
{
  yen.aspects.nix-daemon-containment = {
    at = yen.kinds.host;
    nixos = {
      systemd.slices.nix-daemon.sliceConfig = {
        MemoryHigh = "60%";
        MemoryMax = "85%";
        ManagedOOMMemoryPressure = "kill";
        ManagedOOMMemoryPressureLimit = "50%";
      };
      systemd.services.nix-daemon.serviceConfig = {
        Slice = "nix-daemon.slice";
        OOMScoreAdjust = 500;
      };
      systemd.services.nix-gc.serviceConfig = {
        CPUSchedulingPolicy = "batch";
        IOSchedulingClass = "idle";
      };
    };
  };
}
