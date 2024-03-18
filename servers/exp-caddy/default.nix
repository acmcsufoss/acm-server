let sources = import ../../nix/sources.nix;

in import "${sources.nixpkgs}/nixos" {
	system = "x86_64-linux";
	configuration = { config, lib, pkgs, modulesPath, ... }: {
		imports = [
			(modulesPath + "/virtualisation/qemu-vm.nix")
			../base.nix
		];

		# Forward host connections to 8080 to guest's 8080.
		virtualisation.forwardPorts = [
			{
				from = "host";
				host.port  = 8080;
				guest.port = 8080;
			}
		];

		services.diamondburned.caddy = {
			enable = true;
			configFile = pkgs.writeText "Caddyfile" ''
				http://:8080 {
					respond "Hello, world!"
				}
			'';
		};
	};
}
