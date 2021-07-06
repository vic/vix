{ nixpkgs, self, ... }: {pkgs, lib, ...}: { 

   shellEnv = name: shell:
     with lib;
     let
      drv = pkgs.runCommand name {} ''
	source ${shell.inputDerivation}
	declare -x nobuildPhase="true"
	$_derivation_original_builder $_derivation_original_args
	grep -v -e HOME= -e TMP= $NIX_BUILD_TOP/env-vars > $out
	'';
     in
      builtins.toPath drv; # pkgs.runCommand name {} "${script} $out";

 }
