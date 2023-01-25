{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.diamondburned.caddy;

in {
	options.services.diamondburned.caddy = {
		enable = mkEnableOption "Caddy web server";

		configFile = mkOption {
			example = pkgs.writeText "Caddyfile" ''
				example.com {
					gzip
					minify
					log syslog

					root /srv/http
				}
			'';
			type = types.path;
			description = "Configuration file to use with adapter";
		};

		adapter = mkOption {
			default = "caddyfile";
			type = types.str;
			description = "Type of config given";
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

		openFirewall = mkEnableOption "Port-forward 80 and 443";

		package = mkOption {
			default = pkgs.callPackage ./default.nix {};
			type = types.package;
			description = "Caddy package to use.";
		};
	};

	config = mkIf cfg.enable {
		networking.firewall = mkIf cfg.openFirewall {
			allowedTCPPorts = [ 80 443 ];
			allowedUDPPorts = [ 80 443 ]; # SPDY/QUIC soon.
		};

		systemd.services.caddy = {
			description = "Caddy web server";
			after    = [ "network-online.target" ];
			wantedBy = [ "multi-user.target"     ];
			reloadIfChanged = true;
			environment = cfg.environment;
			serviceConfig = {
				ExecStart = ''
					${cfg.package}/bin/caddy run \
						--environ                \
						--config  ${cfg.configFile}  \
						--adapter ${cfg.adapter} \
				'';
				ExecReload = ''
					${cfg.package}/bin/caddy reload \
						--config  ${cfg.configFile}  \
						--adapter ${cfg.adapter} \
				'';
				TimeoutStopSec = "5s";
				Type  = "notify";
				User  = "caddy";
				Group = "caddy";
				Restart = "on-failure";
				AmbientCapabilities   = [ "cap_net_bind_service" "cap_net_raw" ];
				CapabilityBoundingSet = [ "cap_net_bind_service" "cap_net_raw" ];
				NoNewPrivileges = true;
				StateDirectory = "caddy";
				LimitNPROC  = 8192;
				LimitNOFILE = 1048576;
				PrivateTmp    = false;
				ProtectSystem = "full";
			};
		};

		users.users.caddy = {
			group = "caddy";
			uid = config.ids.uids.caddy;
			home = cfg.dataDir;
			createHome = true;
		};

		users.groups.caddy.gid = config.ids.uids.caddy;
	};
}
