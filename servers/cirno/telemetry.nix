{ config, lib, pkgs, ... }:

{
	# Enable netdata, which is a lightweight alternative to Grafana.
	# https://nixos.wiki/wiki/Netdata
	# https://dataswamp.org/~solene/2022-09-16-netdata-cloud-nixos.html
	services.netdata = {
		enable = true;
		config = {
			global = {
				# Disable storage of metrics on disk.
				"memory mode" = "none";
			};
			web = {
				# Disable the web UI.
				"mode" = "none";
				"accept a streaming request every seconds" = 0;
			};
		};
		configDir = {
			"stream.conf" = pkgs.writeText "stream.conf" ''
				[stream]
					enabled = yes
					api key = ${builtins.readFile <acm-aws/secrets/netdata-key>}
					destination = cs306:19999
			'';
		};
	};

	# Gather system metrics using Telegraf into cirno's VictoriaMetrics.
	services.telegraf = {
		enable = true;
		extraConfig = {
			inputs = {
				net    = {};
				mem    = {};
				disk   = {};
				swap   = {};
				system = {};
				diskio = {};
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
}
