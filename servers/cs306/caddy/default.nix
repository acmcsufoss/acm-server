{ config, lib, pkgs, ... }:

let
	preprocessedCaddyfile = pkgs.runCommandLocal "Caddyfile-preprocessed" {} ''
		cp ${./Caddyfile} $out

		# Ensure that all acmcsuf.com domains are prefixed with "http://".
		# Otherwise, Caddy will refuse to listen on port 80 at all, which
		# we want for our reverse proxy in cirno.
		sed -i 's/\(^\|, \)\([a-zA-Z0-9]*\.acmcsuf.com\)/\1http:\/\/\2/g' $out
	'';
in

{
	services.diamondburned.caddy = {
		enable = true;
		configFile = preprocessedCaddyfile;
		environment = import <acm-aws/secrets/caddy-env.nix>;
	};
}
