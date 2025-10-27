{

  # Creates an aspect that allows
  # unfree packages on dynamic nix clases.
  #
  # usage:
  #   den.aspects.my-laptop.includes = [
  #      (vix.unfree [ "cursor" ])
  #   ]
  vix.unfree = allowed-names: {
    __functor =
      _:
      { class, aspect-chain }:
      {
        ${class} =
          { lib, ... }:
          {
            nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) allowed-names;
          };
      };
  };

}
