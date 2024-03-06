{ config, lib, pkgs, ... }:

with lib;

let
	self = config.acm.services;

	serviceConfigs' = concatMapAttrs
		(name: service: {
			systemd.services.${name} = {
				description = "Managed ACM service for ${name}";
				after = [ "network-online.target" ];
				wants = [ "network-online.target" ];
				wantedBy = [ "multi-user.target" ];
				inherit (service)
					script
					paths
					environment;
				serviceConfig = {
					Type = "simple";
					DynamicUser = true;
					StateDirectory = "acm-services/${name}";
					WorkingDirectory =
						if service.workingDirectory != null then
							service.workingDirectory
						else
							"/var/lib/acm-services/${name}";
				};

				environment = service.environment;
				script = service.script;
			};
		})
		(self);
in

{
	options.acm.services = mkOption {
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
						Paths that should be mounted as read-only inside the service's container/environment.
					''; 
				};
				workingDirectory = lib.mkOption {
					type = types.nullOr types.path;
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
				paths = lib.mkOption {
					type = types.listOf types.path;
					default = [];
					description = ''
						Paths that should be mounted inside the service's isolated environment.
					'';
				};
			};
		});
	};

	config = mkIf (self != {}) serviceConfigs;
}
