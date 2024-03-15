# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
	imports = [ # Include the results of the hardware scan.
		<acm-aws/servers/base.nix>
		# <acm-aws/containers/cs306/test.nix>
		./hardware-configuration.nix
		./services.nix
		./recovery.nix
		./telemetry.nix
		./caddy
	];

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "cs306"; # Define your hostname.
	networking.networkmanager.enable = true;

	networking.firewall.enable = true; # Enable the firewall.
	networking.firewall.allowedTCPPorts = [ ];
	networking.firewall.allowedUDPPorts = [ ];

	# Set your time zone.
	time.timeZone = "America/Los_Angeles";

	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";

	i18n.extraLocaleSettings = {
		LC_ADDRESS = "en_US.UTF-8";
		LC_IDENTIFICATION = "en_US.UTF-8";
		LC_MEASUREMENT = "en_US.UTF-8";
		LC_MONETARY = "en_US.UTF-8";
		LC_NAME = "en_US.UTF-8";
		LC_NUMERIC = "en_US.UTF-8";
		LC_PAPER = "en_US.UTF-8";
		LC_TELEPHONE = "en_US.UTF-8";
		LC_TIME = "en_US.UTF-8";
	};

	nixpkgs.config.allowUnfree = true;

	# Bump this to force Terraform to re-create the instance.
	environment.etc."fuck-ups".text = "1";

	environment.systemPackages = with pkgs; [
		vim
		wget

		# Poentially useful utilities.
		zellij
		croc
	];

	services.openssh.enable = true;

	services.tailscale = {
		enable = true;
		openFirewall = true;
		useRoutingFeatures = "both";
	};

	services.logind.extraConfig = ''
		# Disable the power button
		HandlePowerKey=ignore
	'';

	networking.firewall.interfaces.tailscale0 = {
		allowedTCPPortRanges = [ { from = 0; to = 65535; } ];
		allowedUDPPortRanges = [ { from = 0; to = 65535; } ];
	};

	# Enable wake-on-LAN for Ethernet.
	networking.interfaces.enp8s0.wakeOnLan.enable = true;

	# Enable incus with reproducible config
	# Manual changes will cause irreproducibility - do not edit outside of this!
	# Test any changes before pushing, particularly with networking
	virtualisation.incus.enable = true;
	virtualisation.incus.preseed = {
		networks = [
			{
				config = {
					"ipv4.address" = "172.16.100.1/24";
					"ipv4.nat" = "true";
					"ipv4.firewall" = "false";
					"ipv6.firewall" = "false";
				};
				name = "incusbr0";
				type = "bridge";
			}
		];
		profiles = [
			{
				devices = {
					eth0 = {
						name = "eth0";
						network = "incusbr0";
						type = "nic";
					};
					root = {
						path = "/";
						pool = "default";
						size = "200GiB";
						type = "disk";
					};
				};
			}
		];
		storage_pools = [
			{
				config = {
					source = "/var/lib/incus/storage-pools/default";
				};
				driver = "dir";
				name = "default";
			}
		];
	};

	system.stateVersion = "23.05"; # Did you read the comment?
}
