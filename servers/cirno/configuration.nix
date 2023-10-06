{ config, lib, pkgs, modulesPath, ... }:

let
	sources = import <acm-aws/nix/sources.nix>;
in

{
	imports = [
		(modulesPath + "/virtualisation/amazon-image.nix")
		<acm-aws/servers/base.nix>
	];

	networking.hostName = "cirno";

	services.tailscale.enable = true;

	# Use Terraform's AWS rules for this.
	networking.firewall.enable = false;

	services.diamondburned.caddy = {
		enable = true;
		configFile = ./Caddyfile;
		environment = import <acm-aws/secrets/caddy-env.nix>;
	};

	systemd.services.acmregister = {
		enable = true;
		description = "ACM member registration Discord bot";
		after = [ "network-online.target" ];
		wantedBy = [ "multi-user.target" ];
		environment = import ./secrets/acmregister-env.nix;
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pkgs.acmregister}/bin/acmregister";
			Restart = "on-failure";
			RestartSec = "1s";
		};
	};

	systemd.services.sendlimiter =
		let
			extraArgs = [];
			secrets = import <acm-aws/secrets/sendlimiter.nix>;
			args = lib.concatStringsSep
				" "
				(map lib.escapeShellArg (extraArgs ++ secrets.channelIDs));
		in {
			enable = true;
			description = "Send limiter Discord bot";
			after = [ "network-online.target" ];
			wantedBy = [ "multi-user.target" ];
			environment = {
				BOT_TOKEN = secrets.botToken;
			};
			serviceConfig = {
				Type = "simple";
				ExecStart = "${pkgs.sendlimiter}/bin/sendlimiter ${args}";
				Restart = "on-failure";
				RestartSec = "1s";
			};
		};

	systemd.services.discord-ical-reminder =
		let
			configFile = pkgs.writeText "discord-ical-reminder.json"
				(builtins.toJSON (import ./secrets/ical-reminders.nix));
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
		environment = import ./secrets/discord-ical-srv-env.nix;
		serviceConfig = {
			Type = "simple";
			DynamicUser = true;
			Restart = "on-failure";
			RestartSec = "1s";
			RuntimeDirectory = "discord-ical-srv";
			RuntimeDirectoryMode = "0777";
		};
		script = ''
			${pkgs.discord-ical-srv}/bin/discord-ical-srv \
				-l unix:///$RUNTIME_DIRECTORY/http.sock
		'';
	};

	# Enable VictoriaMetrics, which is a lightweight alternative to InfluxDB.
	# VictoriaMetrics also seems to have better compression and performance.
	# It's used for storing metrics from Telegraf.
	services.victoriametrics = {
		enable = true;
		listenAddress = ":8428";
		retentionPeriod = 3; # months
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
					urls = [ "http://localhost:8428" ];
				};
			};
		};
	};

	# Also host the dashboard here.
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

	environment.systemPackages = with pkgs; [
		ncdu
	];
}
