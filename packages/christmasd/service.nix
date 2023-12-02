{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
	testCfg = config.services.christmasd-test;

	joinFlagAttrs = flagAttrs:
		concatStringsSep
			" "
			(map
				(attr: "--${attr}=${flagAttrs.${attr}}")
				(builtins.attrNames flagAttrs));
in

{
	options.services.christmasd-test = {
		enable = mkEnableOption "Enable christmasd-test";
	
		ledPointsFile = mkOption {
			type = types.path;
			description = "Path to the led-points.csv file";
		};

		extraFlags = mkOption {
			type = types.attrsOf types.str;
			default = {};
			description = "Extra flags to pass to christmasd-test";
		};

		package = mkOption {
			type = types.package;
			default = pkgs.callPackage ./default.nix {};
			description = "The package to use for christmasd";
		};
	};

	config = {
		systemd.services.christmasd-test = mkIf testCfg.enable {
			description = "christmasd-test";
			wantedBy = [ "multi-user.target" ];
			after = [ "network.target" ];
			script = ''
				${testCfg.package}/bin/christmasd-test \
					--led-points ${testCfg.ledPointsFile} ${joinFlagAttrs testCfg.extraFlags}
			'';
			serviceConfig = {
				Restart = "always";
				RestartSec = "5";
				StandardOutput = "journal+console";
				StandardError = "journal+console";
				DynamicUser = true;
				RuntimeDirectory = "christmasd-test";
				RuntimeDirectoryMode = "0777";
				UMask = "0000";
			};
		};
	};
}
