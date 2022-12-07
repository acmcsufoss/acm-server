{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.dischord;
	configPath = pkgs.writeTextFile {
		name = "dischord-pwd";
		text = cfg.config;
		destination = "/config.toml";
	};

in {
	options.services.dischord = {
		enable = mkEnableOption "Dischord";

		config = mkOption {
			type = types.str;
			default = "";
			description = "Dischord configuration in TOML.";
		};

		package = mkOption {
			type = types.package;
			default = pkgs.callPackage ./. { };
			description = "Dischord package to use.";
		};
	};

	config = mkIf cfg.enable {
		environment.systemPackages = [ cfg.package ];

		systemd.services.dischord = {
			description = "Dischord";
			after = [ "network-online.target" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				ExecStart = "${cfg.package}/bin/dischord";
				WorkingDirectory = "${configPath}";
				DynamicUser = true;
				PrivateTmp = true;
				ProtectSystem = "full";
			};
		};
	};
}
