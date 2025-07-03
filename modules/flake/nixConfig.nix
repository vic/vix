{

  flake-file = {
    description = "Vic's Nix Environment";

    nixConfig = {
      allow-import-from-derivation = true;
      extra-trusted-public-keys = [
        "vix.cachix.org-1:hP/Lpdsi1dB3AxK9o6coWh+xHzvAc4ztdDYuG7lC6dI="
      ];
      extra-substituters = [ "https://vix.cachix.org" ];
    };
  };

}
