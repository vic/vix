{ inputs, ... }:
let
  inherit (inputs.self.lib.mk-os)
    wsl
    linux
    linux-arm
    darwin
    darwin-intel
    ;

  flake.nixosConfigurations = {
    annatar = wsl "annatar";
    mordor = linux "mordor";
    nargun = linux "nargun";
    smaug = linux "smaug";
    nienna = linux "nienna";
    tom = linux "tom";
    bombadil = linux "bombadil";
    bill = linux-arm "bill";
  };

  flake.darwinConfigurations = {
    yavanna = darwin-intel "yavanna";
    varda = darwin "varda";
    bert = darwin "bert";
  };

in
{
  inherit flake;
}
