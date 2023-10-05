{ config, lib, pkgs, modulesPath, ... }:

let
	sources = import <acm-aws/nix/sources.nix>;
in

{
	imports = [
		(modulesPath + "/virtualisation/amazon-image.nix")
		<acm-aws/servers/base.nix>
	];

	services.tailscale.enable = true;

	services.diamondburned.caddy = {
		enable = true;
		configFile = ./Caddyfile;
		environment = import <acm-aws/secrets/caddy-env.nix>;
	};

	services.dischord = {
		enable = true;
		config = builtins.readFile ./secrets/dischord-config.toml;
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

	systemd.services.acm-nixie = {
		enable = true;
		description = "acmCSUF's version of the nixie bot.";
		after = [ "network-online.target" ];
		wantedBy = [ "multi-user.target" ];
		environment = import ./secrets/acm-nixie-env.nix;
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pkgs.acm-nixie}/bin/acm-nixie";
			DynamicUser = true;
			StateDirectory = "acm-nixie";
			ReadWritePaths = [ "/var/lib/acm-nixie" ];
		};
	};

	systemd.services.triggers = {
		enable = true;
		description = "Triggers (Crying Counter) Discord bot";
		after = [ "network-online.target" ];
		wantedBy = [ "multi-user.target" ];
		environment = import ./secrets/triggers-env.nix;
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
		environment = import ./secrets/pomo.nix;
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pkgs.pomo}/bin/pomo";
			DynamicUser = true;
			Restart = "on-failure";
			RestartSec = "1s";
		};
	};

	systemd.services.sendlimiter =
		let
			extraArgs = [];
			secrets = import ./secrets/sendlimiter.nix;
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

	environment.systemPackages = with pkgs; [
		ncdu
	];
}
