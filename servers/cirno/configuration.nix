{ config, lib, pkgs, ... }:

{
	imports = [
		../base.nix
	];

	services.diamondburned.caddy = {
		enable = true;
		config = builtins.readFile ./secrets/Caddyfile;
		environment = import ./secrets/caddy-env.nix;
	};

	services.diamondburned.sysmet = {
		http = {
			enable = true;
			address = "127.0.0.1:40001";
		};
		update = {
			enable = true;
			onCalendar = "minutely";
		};
		delete = {
			enable = true;
			maxDays = 30;
			onCalendar = "weekly";
		};
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

	services.fcron = {
		enable = true;
		maxSerialJobs = 4;
		systab = ''
			# Run every 5 minutes
			* * * * * ${pkgs.sysmet}/bin/sysmet --cron
		'';
	};

	environment.systemPackages = with pkgs; [];
}
