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

	environment.systemPackages = with pkgs; [
		ncdu
	];
}
