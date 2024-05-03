{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
	self = config.services.sshwifty;
in

{
	options.services.sshwifty = {
		enable = mkEnableOption "sshwifty server";

		config = mkOption {
			type = types.attrs;
			description = ''
				Verbatim JSON configuration for sshwifty
				See https://github.com/nirui/sshwifty?tab=readme-ov-file#configuration-file-option-and-descriptions.
			'';
		};

		package = mkOption {
			type = types.package;
			default = pkgs.sshwifty;
			description = "The sshwifty package to use.";
		};
	};

	config = mkIf self.enable {
		systemd.services.sshwifty = {
			description = "sshwifty server";
			wantedBy = [ "multi-user.target" ];
			after = [ "network.target" ];
			environment = {
				SSHWIFTY_CONFIG = pkgs.writeText "sshwifty.json" (builtins.toJSON self.config);
			};
			serviceConfig = {
				ExecStart = "${lib.getExe self.package}";
				DynamicUser = true;
				ProtectSystem = "strict";
				ProtectHome = true;
				PrivateTmp = true;
				PrivateDevices = true;
			};
		};
	};
}
