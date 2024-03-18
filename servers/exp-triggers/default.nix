let sources = import ../../nix/sources.nix;

in import "${sources.nixpkgs}/nixos" {
	system = "x86_64-linux";
	configuration = { config, lib, pkgs, modulesPath, ... }: {
		imports = [
			(modulesPath + "/virtualisation/qemu-vm.nix")
			../base.nix
		];

		services.getty.autologinUser = "root";
		users.extraUsers.root.initialHashedPassword = "";

		environment.systemPackages = with pkgs; [
			vim
		];

		systemd.services.crying-counter = {
			enable = true;
			description = "Crying counter Discord bot";
			after = [ "network-online.target" ];
			wantedBy = [ "multi-user.target" ];
			environment = import ../cirno/secrets/crying-counter-env.nix;
			serviceConfig = {
				Type = "simple";
				ExecStart = "${pkgs.crying-counter}/bin/crying-counter";
				DynamicUser = true;
			};
		};
	};
}
