# power: scx_lavd follows the power profile on laptops; thermald on intel laptops.
{ yen, at, ... }:
{
  yen.aspects.laptop-power = {
    at = yen.aspects.laptop;
    nixos.services.scx-loader = {
      enable = true;
      config.scheduler = "scx_lavd";
      config.extraArgs = [ "--autopower" ];
    };
  };

  yen.aspects.laptop-thermald = {
    at = at.all [
      yen.aspects.laptop
      (yen.kinds.host.where { cpu = yen.cpu.intel; })
    ];
    nixos.services.thermald.enable = true;
  };
}
