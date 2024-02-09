{ config, lib, pkgs, ... }:

let
	podmanServiceName = containerName: "podman-" + containerName;
in

{
	virtualisation.oci-containers =
		let
			inherit (import ./image.nix { inherit pkgs; }) imageFile;
		in
		{
			backend = "podman";
			containers = {
				"experimental-discord-bot" = {
					autoStart = true;
					environment = {
						TEST_ENV1 = "test1";
						TEST_ENV2 = "test2";
					};
					ports = [
						"127.0.0.1:48765:80"
					];
					image = "experimental-discord-bot-image:latest";

					inherit imageFile;
				};
			};
		};

	systemd.services.${podmanServiceName "experimental-discord-bot"} = with lib; {
		serviceConfig.RestartSec = mkForce "5s";
		startLimitBurst = mkForce 3;
		startLimitIntervalSec = mkForce (5 * 60); # 5 minutes
	};
}
