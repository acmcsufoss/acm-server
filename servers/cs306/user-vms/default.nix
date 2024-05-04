{ config, lib, pkgs, ... }:

let
	usersFile = <acm-aws/user-machines/secrets/user-vms.json>;

	inherit (import <acm-aws/user-machines/vm/config.nix> { inherit pkgs; })
		hostOrderToIP
		ips;

	findUserIDWithIP =
		ip:
		lib.findFirst (user: user.ip == ip) null config.acm.user-vms.usersInfo;

	vpsFiles = pkgs.runCommand "www-vps.acmcsuf.com" {
		nativeBuildInputs = with pkgs; [
			gomplate
		];
	} ''
		mkdir $out

		gomplate \
			--file ${./vps.html} \
			--out $out/index.html \
			--datasource users=file://${usersFile} \
			--datasource users-info=file://${pkgs.writeText "usersInfo.json" (builtins.toJSON config.acm.user-vms.usersInfo)}
	'';
in

{
	imports = [
		<acm-aws/user-machines/vm>
	];

	acm.user-vms = {
		enable = true;
		users = builtins.fromJSON (builtins.readFile usersFile);
		# Pin all CPU usages to the 4 host cores.
		cpuPinning = [4 5 6 7];
		poolDirectory = "/var/lib/acm-vm";
	};

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

	services.diamondburned.caddy.sites =
		{
			"http://ssh.acmcsuf.com" = ''
				reverse_proxy * localhost:38274
			'';
			"http://vps.acmcsuf.com" = ''
				header Cache-Control "must-revalidate"
				handle /vps.json {
					root * ${pkgs.writeTextDir "vps.json" (builtins.toJSON config.acm.user-vms.usersInfo)}
					file_server
				}
				handle {
					root * ${vpsFiles}
					file_server
				}
			'';
		} // (builtins.listToAttrs (map (user: {
			name = "http://${user.id}.vps.acmcsuf.com";
			value = ''
				reverse_proxy * http://${user.ip}:80
			'';
		}) config.acm.user-vms.usersInfo));
}
