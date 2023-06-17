{ config, lib, pkgs, modulesPath, ... }:

{
	imports = [
		(modulesPath + "/virtualisation/amazon-image.nix")
		<acm-aws/servers/base.nix>
	];

	services.diamondburned.caddy = {
		enable = true;
		configFile = ./secrets/Caddyfile;
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
		enable = false;
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

	environment.systemPackages = with pkgs; [
		ncdu
	];
}
