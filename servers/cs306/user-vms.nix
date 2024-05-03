{ config, lib, pkgs, ... }:

let
	inherit (import <acm-aws/user-machines/vm/config.nix> { inherit pkgs; })
		hostOrderToIP
		ips;

	findUserIDWithIP =
		ip:
		lib.findFirst (user: user.ip == ip) null config.acm.user-vms.usersInfo;
in

{
	imports = [
		<acm-aws/user-machines/vm>
	];

	acm.user-vms = {
		enable = true;
		users = builtins.fromJSON (builtins.readFile <acm-aws/user-machines/secrets/user-vms.json>);
		# Pin all CPU usages to the 4 host cores.
		cpuPinning = [4 5 6 7];
		poolDirectory = "/var/lib/acm-vm";
	};

	services.diamondburned.caddy.sites."http://vps.acmcsuf.com" = ''
		root * ${pkgs.writeTextDir "vps.json" (builtins.toJSON config.acm.user-vms.usersInfo)}
		rewrite * /vps.json
		header Cache-Control "must-revalidate"
		file_server
	'';

	services.sshwifty = {
		enable = true;
		config = {
			Servers = [
				{
					ListenInterface = "127.0.0.1";
					ListenPort = 38274;
				}
			];
			Presets = map
				(order:
					let
						ip   = hostOrderToIP order;
						user = findUserIDWithIP ip;
					in
					{
						Title =
							if user != null then "${user.id} (${ip})" else "${ip}";
						Type = "SSH";
						Host = "${ip}:22";
					}
				)
				(ips.range);
			OnlyAllowPresetRemotes = true;
		};
	};

	services.diamondburned.caddy.sites."http://ssh.acmcsuf.com" = ''
		reverse_proxy * localhost:38274
	'';
}
