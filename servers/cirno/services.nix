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

	# systemd.services."fullyhacks-qrms" =
	# 	let
	# 		tokenFile = <acm-aws/secrets/fullyhacks-token.txt>;
	# 		port = 38574;
	# 	in
	# 		{
	# 			enable = true;
	# 			description = "Fullyhacks QR Management System";
	# 			after = [ "network-online.target" ];
	# 			wantedBy = [ "multi-user.target" ];
	# 			serviceConfig = {
	# 				Type = "simple";
	# 				DynamicUser = true;
	# 				ReadOnlyPaths = [ tokenFile ];
	# 				StateDirectory = "fullyhacks-qrms";
	# 			};
	# 			script = ''
	# 				${pkgs.fullyhacks-qrms}/bin/fullyhacks-qrms \
	# 					--root-token-file "${tokenFile}" \
	# 					--addr ":${builtins.toString port}" \
	# 					--db "$STATE_DIRECTORY/database.db"
	# 			'';
	# 		};
}
