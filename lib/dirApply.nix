{lib, ...}: app: dir: 
lib.pipe dir [
  builtins.readDir
  (lib.mapAttrsToList (name: _: 
    if lib.strings.match "^_.*" name != null then []
    else [{
      name = lib.replaceStrings [".nix"] [""] name;
      value = app "${dir}/${name}";
    }]
  ))
  lib.flatten
  lib.listToAttrs
]
