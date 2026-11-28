# sysctl: inotify limits, bbr + fq, zram-friendly vm settings; on every linux host/guest.
{ yen, ... }:
{
  yen.aspects.sysctl = {
    at = yen.kinds.linux;
    nixos =
      { config, lib, ... }:
      {
        boot.kernel.sysctl = lib.mkMerge [
          {
            "fs.inotify.max_user_watches" = 1048576;
            "fs.inotify.max_user_instances" = 1024;
            "net.core.default_qdisc" = "fq";
            "net.ipv4.tcp_congestion_control" = "bbr";
          }
          (lib.mkIf config.zramSwap.enable {
            "vm.swappiness" = 100;
            "vm.page-cluster" = 0;
          })
        ];
      };
  };
}
