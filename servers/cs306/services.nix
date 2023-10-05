{ config, lib, pkgs, ... }:

{
	imports = [
		./caddy
		];
	
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
}
