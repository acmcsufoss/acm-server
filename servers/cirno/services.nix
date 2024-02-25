{ config, lib, pkgs, ... }:

let
	sources = import <acm-aws/nix/sources.nix>;
in

{
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

	services.christmasd-test = {
		enable = true;
		ledPointsFile = builtins.fetchurl
			"https://gist.githubusercontent.com/diamondburned/1d9a83347e153686ca192c6f5baf0b79/raw/63b06ed82fd858bdb8b15a5971df92dd4bab40c3/led-points.csv";
		extraFlags = {
			http-addr = "unix://$RUNTIME_DIRECTORY/http.sock";
		};
	};

	systemd.services."fullyhacks-qrms" =
		let
			tokenFile = <acm-aws/secrets/fullyhacks-token.txt>;
			port = 38574;
		in
			{
				enable = true;
				description = "Fullyhacks QR Management System";
				after = [ "network-online.target" ];
				wantedBy = [ "multi-user.target" ];
				serviceConfig = {
					Type = "simple";
					DynamicUser = true;
					ReadOnlyPaths = [ tokenFile ];
					StateDirectory = "fullyhacks-qrms";
				};
				script = ''
					${pkgs.fullyhacks-qrms}/bin/fullyhacks-qrms \
						--root-token-file "${tokenFile}" \
						--addr ":${builtins.toString port}" \
						--db "$STATE_DIRECTORY/database.db"
				'';
			};
}
