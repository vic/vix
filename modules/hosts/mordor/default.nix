# mordor: workstation with an nvidia card (ref-typed cpu, gpu, desktops).
{ yen, ... }:
{
  yen.host.mordor = {
    system = yen.system.x86_64-linux;
    users = [ yen.user.vic ];
    trusted = true;
    workstation = true;
    cpu = yen.cpu.amd;
    gpu = yen.gpu.nvidia;
    desktops = [ yen.desktop.xfce ];
  };
}
