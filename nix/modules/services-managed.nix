{ config, lib, pkgs, ... }:

with lib;

let
	self = config.services.managed;
in

{
	options.services.managed = {
		enable = mkEnableOption "Enable management of declared services";

		services = mkOption {
			description = ''
				Configuration for the services to be run as an isolated systemd service.
			'';
			type = types.attrsOf (types.submodule {
				options = {
					script = lib.mkOption {
						type = types.str;
						description = ''
							The startup script for the service.
						'';
					};
					readOnlyPaths = lib.mkOption {
						type = types.listOf types.path; 
						default = [];
						description = ''
							Paths that should be mounted as read-only inside the service's
							container/environment.
						'';
					};
					workingDirectory = lib.mkOption {
						type = types.nullOr types.path;
						default = null;
						description = ''
							The working directory to be used for the service.
							If null, then the state directory is used.
						'';
					};
					environment = lib.mkOption {
						type = types.attrsOf types.str;
						default = {};
						description = ''
							Environment variables to be set for the service.
						'';
					};
					environmentFile = lib.mkOption {
						type = types.listOf types.path;
						default = [];
						description = ''
							Environment files to be sourced for the service.
						'';
					};
					path = lib.mkOption {
						type = types.listOf types.path;
						default = [];
						description = ''
							Paths that should be mounted inside the service's isolated
							environment.
						'';
					};
					serviceConfig = lib.mkOption {
						type = types.attrs;
						default = {};
						description = ''
							Additional systemd service configuration.
						'';
					};
				};
			});
		};
	};

	config = mkIf self.enable {
		systemd.services = mapAttrs
			(name: service: {
				inherit (service)
					script
					path
					environment;
				description = "Managed ACM service for ${name}";
				after = [ "network-online.target" ];
				wants = [ "network-online.target" ];
				wantedBy = [ "multi-user.target" ];
				serviceConfig = {
					Type = "simple";
					DynamicUser = true;
					ProtectSystem = "strict";
					ProtectHome = true;
					PrivateDevices = true;
					StateDirectory = "${name}";
					RuntimeDirectory = "${name}";
					RuntimeDirectoryMode = "0777";
					UMask = "0000";
					WorkingDirectory =
						if service.workingDirectory != null then
							service.workingDirectory
						else
							"/var/lib/${name}"; # default to state directory
					Restart = "on-failure";
					RestartSec = "2s";
				} // service.serviceConfig;
			})
			(self.services);
	};
}
