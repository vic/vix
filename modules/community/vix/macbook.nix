{ vix, ... }:
{
  # Intel Apple laptops: macOS-style keys, KVM, Broadcom wifi.
  vix.macbook.includes = [
    vix.macos-keys
    vix.kvm-intel
    vix.wl-broadcom
  ];
}
