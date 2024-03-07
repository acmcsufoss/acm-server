{ config, lib, pkgs, ... }:

let
	tailnet = builtins.getEnv "TAILNET_NAME";
	tailnetAddr = name: "${name}.${tailnet}.ts.net";
in

assert lib.assertMsg
	(tailnet != null && tailnet != "")
	"$TAILNET_NAME environment variable must be set, are you in the nix-shell?";

{
	services.telegraf = {
		enable = true;
		extraConfig = {
			inputs = {
				# TODO: per-service procstat
				net      = {};
				mem      = {};
				cpu      = { percpu = true; totalcpu = true; };
				disk     = {};
				swap     = {};
				temp		 = {};
				system   = {};
				kernel   = {}; # ctx switch go brr
				diskio   = {};
				processes = {};
				prometheus = {
					urls = [
						"http://localhost:2019/metrics" # Caddy
					];
				};
				systemd_units = {};
				internet_speed = {
					interval = "2h";
				};
			};
			outputs = {
				influxdb = {
					database = "telegraf";
					urls = [ "http://cs306:8428" ];
				};
			};
		};
	};

	# Enable VictoriaMetrics, which is a lightweight alternative to InfluxDB.
	# VictoriaMetrics also seems to have better compression and performance.
	# It's used for storing metrics from Telegraf.
	services.victoriametrics = {
		enable = true;
		listenAddress = ":8428";
		retentionPeriod = 3; # months
	};

	services.grafana = {
		enable = true;
		settings = {
			server = {
				http_addr = "0.0.0.0";
				http_port = 38573;
				domain = "status.acmcsuf.com";
				root_url = "https://status.acmcsuf.com";
				enable_gzip = true;
			};
			security = {
				disable_initial_admin_creation = false;
				cookie_secure = true;
				cookie_samesite = "strict";
				angular_support_enabled = false;
			};
			feature_toggles = {
				publicDashboards = true;
			};
		};
	};

	# Enable netdata, which is a lightweight alternative to Grafana.
	# https://nixos.wiki/wiki/Netdata
	# https://dataswamp.org/~solene/2022-09-16-netdata-cloud-nixos.html
	services.netdata = {
		enable = true;
		config =
			with lib;
			with builtins;
			let
				concat = l: concatStringsSep " " (flatten l);
				config = {
					web = rec {
						"web server threads" = 6;
						"default port" = 19999;
						# Keep the allowed addresses to the default and rely on
						# the NixOS firewall to restrict access.
						"bind to" = concat [
							"127.0.0.1"
							"unix:/run/netdata/netdata.sock"
							(map (host: "${tailnetAddr host}=streaming") [ "cirno" ])
						];
					};
				};
			in config;
		configDir = {
			"stream.conf" = pkgs.writeText "stream.conf" ''
				[stream]
					enabled = yes
					enable compression = yes

				[${builtins.readFile <acm-aws/secrets/netdata-key>}]
					enabled = yes
					allow from = 100.*
					default memory mode = dbengine
					health enabled by default = yes
			'';
		};
	};
}
