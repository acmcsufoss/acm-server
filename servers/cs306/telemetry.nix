{ config, lib, pkgs, ... }:

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
}
