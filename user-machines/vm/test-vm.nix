# Usages:
#   nix-build ./user-machines/vm/test-vm.nix
#   $(nix-build -A driverInteractive ./user-machines/vm/test-vm.nix)/bin/nixos-test-driver

let
	pkgs = import <acm-aws/nix/nixpkgs.nix>;
in

pkgs.testers.runNixOSTest {
	name = "user-machines-test";

	nodes.machine = { config, pkgs, lib, ... }: {
		imports = [
			./.
		];

		networking.firewall.enable = false;

		boot.loader.systemd-boot.enable = true;
		boot.loader.efi.canTouchEfiVariables = true;

		# services.xserver = {
		# 	enable = true;
		# 	displayManager = {
		# 		lightdm.enable = true;
		# 		autoLogin = {
		# 			enable = true;
		# 			user = "alice";
		# 		};
		# 	};
		# 	desktopManager = {
		# 		lxqt.enable = true;
		# 	};
		# };

		# users.users.alice = {
		# 	isNormalUser = true;
		# 	extraGroups = [ "wheel" ];
		# 	initialPassword = "password";
		# };
		# security.sudo.wheelNeedsPassword = false;

		# programs.virt-manager.enable = true;

		# Accommodate the large VMs.
		# Base 1GB + 4GB per user.
		virtualisation.diskSize = 1024 + ((lib.length config.acm.user-vms.users) * 4 * 1024);

		acm.user-vms = {
			enable = true;
			users = [
				{
					id = "alice";
					name = "Alice";
					email = ["alice@example.com"];
					discord = "@alice";
					default_password = "password";
					uuid = "f2d0c3a3-5c4b-4b0d-8e4a-9f3c4d1f8d6e";
				}
			];
		};

		environment.systemPackages = with pkgs; [
			# zellij
			tmux
		];

		system.stateVersion = builtins.trace (builtins.toJSON config.acm.user-vms.usersInfo) "22.05";
	};

	testScript = { nodes, ... }: ''
		# TODO: Add tests here
	'';
}
