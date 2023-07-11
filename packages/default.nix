{ pkgs ? import <acm-aws/nix/nixpkgs.nix> }:

rec {
	jre_small = pkgs.callPackage ./jre-small {};

	# Go
	acmregister = pkgs.callPackage ./acmregister { };
	acm-nixie = pkgs.callPackage ./acm-nixie { };
	caddy = pkgs.callPackage ./caddy { };
	sendlimiter = pkgs.callPackage ./sendlimiter { };
	sysmet = pkgs.callPackage ./sysmet { };
	dischord = pkgs.callPackage ./dischord { };

	# Java
	triggers = pkgs.callPackage ./triggers {};

	# Deno
	pomo = pkgs.callPackage ./pomo { };
}
