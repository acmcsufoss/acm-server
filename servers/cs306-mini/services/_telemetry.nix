{ config, lib, pkgs, ... }:

let
	tailnet = builtins.getEnv "TAILNET_NAME";
	tailnetAddr = name: "${name}.${tailnet}.ts.net";
in

assert lib.assertMsg
	(tailnet != null && tailnet != "")
	"$TAILNET_NAME environment variable must be set, are you in the nix-shell?";

{
	# Enable netdata, which is a lightweight alternative to Grafana.
	# https://nixos.wiki/wiki/Netdataa
	# https://dataswamp.org/~solene/2022-09-16-netdata-cloud-nixos.html
	services.netdata = {
		enable = true;
		config =
			with lib;
			with builtins;
			let
				concat = l: concatStringsSep " " (flatten l);
				config = {
					web = rec {
						"web server threads" = 6;
						"default port" = 19999;
						# Keep the allowed addresses to the default and rely on
						# the NixOS firewall to restrict access.
						"bind to" = concat [
							"127.0.0.1"
							(map (host: "${tailnetAddr host}=streaming") [ "cirno" ])
						];
					};
				};
			in config;
		configDir = {
			"stream.conf" = pkgs.writeText "stream.conf" ''
				[stream]
					enabled = yes
					enable compression = yes

				[${builtins.readFile <acm-aws/secrets/netdata-key>}]
					enabled = yes
					allow from = 100.*
					default memory mode = dbengine
					health enabled by default = yes
			'';
		};
	};
}
