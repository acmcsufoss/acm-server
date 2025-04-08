{ config, pkgs, lib, ... }:

with lib;

let
	paths = config.deployment.staticPaths;

	staticDir = pkgs.symlinkJoin {
		name = "deployment-static";
		inherit paths;
	};
in

{
	options.deployment.staticPaths = mkOption {
		type = types.listOf types.path;
		default = [];
		description = ''
			Paths to directories that will be copied into /etc/deployment/static.
		'';
	};

	config = mkIf (paths != []) {
		systemd.tmpfiles.rules = [
			"L+ /etc/deployment/static - - - - ${staticDir}"
		];
	};
}
