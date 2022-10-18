nivSources:
self: super: {
  unison-ucm = let
    inherit (self.stdenvNoCC) mkDerivation;
  in mkDerivation {
    name = "unison-ucm";
    src = nivSources.ucm;
    phases = [ "install" ];
    buildInputs = with self; [ coreutils ];
    install = ''
    mkdir -p $out/bin
    tar -xvf $src -C $out
    ln -s $out/ucm $out/bin/ucm
    '';
  };
}
