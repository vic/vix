# macbook: Intel Apple laptops: macOS-style keys, KVM, Broadcom wifi.
{ ren, ... }:
{
  ren.aspects.macbook.includes = [
    ren.aspects.macos-keys
    ren.aspects.kvm-intel
    ren.aspects.wl-broadcom
  ];
}
