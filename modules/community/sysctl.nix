# sysctl: inotify limits, bbr + fq, zram-friendly vm settings; on every nixos host.
{ ren, ... }:
{
  ren.aspects.sysctl = {
    at = ren.kinds.host;
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
            "vm.swappiness" = 100; # compressed ram is cheaper than a page cache miss
            "vm.page-cluster" = 0; # no readahead on swap
          })
        ];
      };
  };
}
