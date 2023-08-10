{ config, lib, pkgs, modulesPath, ... }:

let
	sources = import <acm-aws/nix/sources.nix>;
in

{
	imports = [
		(modulesPath + "/virtualisation/amazon-image.nix")
		<acm-aws/servers/base.nix>
	];

	services.diamondburned.caddy = {
		enable = true;
		configFile = ./Caddyfile;
		environment = import ./secrets/caddy-env.nix;
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

	environment.systemPackages = with pkgs; [
		ncdu
	];
}
