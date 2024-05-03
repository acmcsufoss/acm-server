{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.diamondburned.caddy;

in {
	options.services.diamondburned.caddy = {
		enable = mkEnableOption "Caddy web server";

		configFile = mkOption {
			example = literalExample ''
				pkgs.writeText "Caddyfile" \'\'
					example.com {
						gzip
						minify
						log syslog

						root /srv/http
					}
				\'\'
			'';
			type = types.path;
			description = "Configuration file to use with adapter";
		};

		sites = mkOption {
			type = types.attrsOf (types.either types.str (types.listOf types.str));
			default = {};
			example = {
				"b.example.com" = ''
					root * /home/b.example.com
					file_server
				'';
			};
			description = ''
				Sites to serve. DO NOT use this for sites with secrets; prefer using the global
				config file for secrets and use `import' to include it in the site config.
				Sites will be appended to the global config file.
			'';
		};

		dataDir = mkOption {
			default = "/var/lib/caddy";
			type = types.path;
			description = ''
				The data directory, for storing certificates. Before 17.09, this
				would create a .caddy directory. With 17.09 the contents of the
				.caddy directory are in the specified data directory instead.
			'';
		};

		environment = mkOption {
			default = {};
			type = types.attrsOf types.str;
			description = "Environment variables to pass to the service";
		};

		environmentFile = mkOption {
			default = null;
			type = types.nullOr types.path;
			description = "File containing environment variables to pass to the service";
		};

		openFirewall = mkEnableOption "Port-forward 80 and 443";

		package = mkOption {
			default = pkgs.caddy;
			type = types.package;
			description = "Caddy package to use.";
		};
	};

	config = mkIf cfg.enable (
		let sitesConfigFile = pkgs.writeText "caddy-sites"
			(concatStringsSep "\n"
				(mapAttrsToList
					(name: value:
						if isList value then
							# For each site, add the name and the value.
							concatStringsSep "\n" (map (v: "${name} {\n${v}\n}") value)
						else
							"${name} {\n${value}\n}"
					)
					(cfg.sites)));

			configPrepare = pkgs.writeShellScript "caddy-wrap" ''
				set -e

				if [[ "$RUNTIME_DIRECTORY" == "" ]]; then
					echo "RUNTIME_DIRECTORY is not set" >&2
					exit 1
				fi

				# Harden.
				:> "$RUNTIME_DIRECTORY/Caddyfile"
				chmod 600 "$RUNTIME_DIRECTORY/Caddyfile"

				cat ${cfg.configFile} >> $RUNTIME_DIRECTORY/Caddyfile
				cat ${sitesConfigFile} >> $RUNTIME_DIRECTORY/Caddyfile

				exec ${cfg.package}/bin/caddy "$@" \
					--config "$RUNTIME_DIRECTORY/Caddyfile" \
					--adapter caddyfile
			'';
		in {
			environment.systemPackages = [ cfg.package ];
	
			networking.firewall = mkIf cfg.openFirewall {
				allowedTCPPorts = [ 80 443 ];
				allowedUDPPorts = [ 80 443 ]; # SPDY/QUIC soon.
			};
	
			systemd.services.caddy = {
				description = "Caddy web server";
				after    = [ "network-online.target" ];
				wantedBy = [ "multi-user.target"     ];
				environment = cfg.environment;
				reloadIfChanged = true;
				serviceConfig = {
					ExecStart = "${configPrepare} run --environ";
					ExecReload = "${configPrepare} reload";
					TimeoutStopSec = "5s";
					Type  = "notify";
					User  = "caddy";
					Group = "caddy";
					Restart = "on-failure";
					AmbientCapabilities   = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
					CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
					NoNewPrivileges = true;
					StateDirectory = "caddy";
					LimitNPROC  = 8192;
					LimitNOFILE = 1048576;
					PrivateTmp    = false;
					ProtectSystem = "full";
					EnvironmentFile = cfg.environmentFile;
					RuntimeDirectory = "caddy";
				};
			};
	
			users.users.caddy = {
				group = "caddy";
				uid = config.ids.uids.caddy;
				home = cfg.dataDir;
				createHome = true;
			};
	
			users.groups.caddy.gid = config.ids.uids.caddy;
		}
	);
}
