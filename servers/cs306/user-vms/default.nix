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
		# Pin all CPU usages to the last 2 cores.
		cpuPinning = [
			2 3 # 3rd core
			6 7 # 4th core
		];
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

	services.diamondburned.caddy.sites = {
		"http://ssh.acmcsuf.com" = ''
			reverse_proxy * localhost:38274
		'';
		"http://vps.acmcsuf.com" = ''
			header Cache-Control "public, no-cache, max-age 86400"
			handle /vps.json {
				root * ${pkgs.writeTextDir "vps.json" (builtins.toJSON config.acm.user-vms.usersInfo)}
				file_server
			}
			handle {
				root * ${vpsFiles}
				file_server
			}
		'';
		"http://*.vps.acmcsuf.com" =
			with lib;
			with builtins;
			(concatStrings (imap0 (i: user: ''
				@user_${toString i} <<CEL
					{host} == "${user.sanitized_id}.vps.acmcsuf.com" ||
					{host}.endsWith(".${user.sanitized_id}.vps.acmcsuf.com")
					CEL
				handle @user_${toString i} {
					reverse_proxy * http://${user.ip}:80
				}
			'') config.acm.user-vms.usersInfo)) +
			''
				handle {
					abort
				}
			'';
	};
}
