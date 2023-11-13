top: vix-lib: flakeModules: flakeModules // { 
  vix-lib.options.vix.lib = top.lib.mkOption {
    default = vix-lib;
    readOnly = true;
  };
}