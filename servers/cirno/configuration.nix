{ config, lib, pkgs, modulesPath, ... }:

{
	imports = [
		(modulesPath + "/virtualisation/amazon-image.nix")
		../base.nix
	];

	services.diamondburned.caddy = {
		enable = true;
		configFile = ./secrets/Caddyfile;
		environment = import ./secrets/caddy-env.nix;
	};

	# services.diamondburned.sysmet = {
	# 	http = {
	# 		enable = true;
	# 		address = "127.0.0.1:40001";
	# 	};
	# 	update = {
	# 		enable = true;
	# 		onCalendar = "*:0/2:00"; # every 2 minutes
	# 	};
	# 	delete = {
	# 		enable = true;
	# 		maxDays = 14;
	# 		onCalendar = "*-*-1/2"; # every 2 days
	# 	};
	# };

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

	environment.systemPackages = with pkgs; [
		# crying-counter-bin
	];
}
