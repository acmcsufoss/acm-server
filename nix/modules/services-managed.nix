{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
	self = config.services.managed;
in

{
	options.services.managed = {
		enable = mkEnableOption "Enable management of declared services";

		services = with types; mkOption {
			description = ''
				Configuration for the services to be run as an isolated systemd service.
			'';
			type = attrsOf (submodule {
				options = {
					description = lib.mkOption {
						type = nullOr str;
						default = null;
						description = ''
							A description of the service.
						'';
					};
					command = lib.mkOption {
						type = nullOr (oneOf [ str (listOf str) ]);
						default = null;
						description = ''
							The startup command for the service.
							This command is not run in a shell.

							If a list of strings is given, then the first string is the
							command and the rest are the arguments. Otherwise, the string
							is the command to be run.

							If `command` and `script` are both null, then `command` takes
							precedence over `script`.
						'';
					};
					script = lib.mkOption {
						type = nullOr lines;
						default = null;
						description = ''
							The startup script for the service.
							This command is run in a shell.

							If `command` and `script` are both null, then `command` takes
							precedence over `script`.
						'';
					};
					readOnlyPaths = lib.mkOption {
						type = listOf path; 
						default = [];
						description = ''
							Paths that should be mounted as read-only inside the service's
							container/environment.
						'';
					};
					workingDirectory = lib.mkOption {
						type = nullOr path;
						default = null;
						description = ''
							The working directory to be used for the service.
							If null, then the state directory is used.
						'';
					};
					environment = lib.mkOption {
						type = attrsOf str;
						default = {};
						description = ''
							Environment variables to be set for the service.
						'';
					};
					environmentFile = lib.mkOption {
						type = listOf path;
						default = [];
						description = ''
							Environment files to be sourced for the service.
						'';
					};
					path = lib.mkOption {
						type = listOf path;
						default = [];
						description = ''
							Paths that should be mounted inside the service's isolated
							environment.
						'';
					};
					serviceConfig = lib.mkOption {
						type = attrs;
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
			(name: service:
				{
					inherit (service)
						path
						environment;

					description = "Managed ACM service for ${name}";
					after = [ "network-online.target" ];
					wants = [ "network-online.target" ];
					wantedBy = [ "multi-user.target" ];

					script =
						if service.command != null then
							if isList service.command then
								"exec ${strings.escapeShellArgs service.command}"
							else
								"exec ${strings.escapeShellArg service.command}"
						else
							service.script;

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
						Restart = "on-failure";
						RestartSec = "2s";

						WorkingDirectory =
							if service.workingDirectory != null then
								service.workingDirectory
							else
								"/var/lib/${name}"; # default to state directory
					} // service.serviceConfig;
				}
			)
			(self.services);
	};
}
