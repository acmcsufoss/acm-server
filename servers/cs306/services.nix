{ config, lib, pkgs, ... }:

let
	sources = import <acm-aws/nix/sources.nix>;
in

{
	imports = [
		./caddy
	];

	# Gather system metrics using Telegraf into cirno's VictoriaMetrics.
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

	systemd.services.discord-ical-reminder =
		let
			configFile = pkgs.writeText "discord-ical-reminder.json"
				(builtins.toJSON (import <acm-aws/secrets/ical-reminders.nix>));
		in
			{
				enable = true;
				description = "Daemon for posting ICal reminders using Discord webhooks";
				after = [ "network-online.target" ];
				wantedBy = [ "multi-user.target" ];
				serviceConfig = {
					Type = "simple";
					ExecStart = "${pkgs.discord-ical-reminder}/bin/discord-ical-reminder -c ${configFile}";
					DynamicUser = true;
					Restart = "on-failure";
					RestartSec = "1s";
				};
			};

	systemd.services.discord-ical-srv = {
		enable = true;
		description = "Discord bot that synchronizes Discord events to a hosted iCal feed";
		after = [ "network-online.target" ];
		wantedBy = [ "multi-user.target" ];
		environment = import <acm-aws/secrets/discord-ical-srv-env.nix>;
		serviceConfig = {
			Type = "simple";
			DynamicUser = true;
			Restart = "on-failure";
			RestartSec = "1s";
			RuntimeDirectory = "discord-ical-srv";
			RuntimeDirectoryMode = "0777";
			UMask = "0000";
		};
		script = ''
			${pkgs.discord-ical-srv}/bin/discord-ical-srv \
				-l unix:///$RUNTIME_DIRECTORY/http.sock
		'';
	};
	
	systemd.services.quizler = {
		enable = true;
		description = "https://github.com/jacobtread/Quizler";
		after = [ "network-online.target" ];
		wantedBy = [ "multi-user.target" ];
		environment = {
			QUIZLER_PORT = "37867"; # see Caddyfile
		};
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pkgs.quizler}/bin/quizler";
			DynamicUser = true;
			Restart = "on-failure";
			RestartSec = "1s";
			# Use strict resource controls since this is an exposed and untrusted
			# service.
			ProtectSystem = "strict";
			ProtectHome = true;
			PrivateDevices = true;
			MemoryMax = "256M";
			TasksMax = 128;
			CPUQuota = "50%";
			RestrictNetworkInterfaces = "lo"; # enough for localhost
		};
	};

	systemd.services.triggers = {
		enable = true;
		description = "Triggers (Crying Counter) Discord bot";
		after = [ "network-online.target" ];
		wantedBy = [ "multi-user.target" ];
		environment = import <acm-aws/secrets/triggers-env.nix>;
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pkgs.triggers}/bin/triggers";
			DynamicUser = true;
			Restart = "on-failure";
			RestartSec = "1s";
		};
	};

	systemd.services.pomo = {
		enable = true;
		description = "Pomodoro timer server/Discord bot";
		after = [ "network-online.target" ];
		wantedBy = [ "multi-user.target" ];
		environment = import <acm-aws/secrets/pomo.nix>;
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pkgs.pomo}/bin/pomo";
			DynamicUser = true;
			Restart = "on-failure";
			RestartSec = "10s";
			StartLimitInterval = "0"; # permit unlimited restarts
		};
	};
	
	systemd.services.acm-nixie = {
		enable = true;
		description = "acmCSUF's version of the nixie bot.";
		after = [ "network-online.target" ];
		wantedBy = [ "multi-user.target" ];
		environment = import <acm-aws/secrets/acm-nixie-env.nix>;
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pkgs.acm-nixie}/bin/acm-nixie";
			DynamicUser = true;
			StateDirectory = "acm-nixie";
			ReadWritePaths = [ "/var/lib/acm-nixie" ];
		};
	};

	services.dischord = {
		enable = true;
		config = builtins.readFile <acm-aws/secrets/dischord-config.toml>;
	};

	systemd.services."goworkshop.acmcsuf.com" =
		let
			shell = import "${sources.go-workshop}/shell.nix" { inherit pkgs; };
			present = shell.present;
		in
			{
				enable = true;
				description = "Go x/tools/present server for goworkshop.acmcsuf.com";
				after = [ "network.target" ];
				wantedBy = [ "multi-user.target" ];
				serviceConfig = {
					ExecStart = "${present}/bin/present --play=true --use_playground --http=127.0.0.1:38572";
					DynamicUser = true;
					WorkingDirectory = "${sources.go-workshop}";
				};
			};

	services.christmasd-test = {
		enable = true;
		ledPointsFile = builtins.fetchurl
			"https://raw.githubusercontent.com/acmCSUFDev/christmas/main/data/fake/led-points.csv";
		extraFlags = {
			http-addr = "unix://$RUNTIME_DIRECTORY/http.sock";
		};
	};
}
