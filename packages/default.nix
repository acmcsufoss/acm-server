{ pkgs ? import <acm-aws/nix/nixpkgs.nix> }:

rec {
	jre_small = pkgs.callPackage ./jre-small {};
	quizler = pkgs.callPackage ./quizler {};

	# Go
	acmregister = pkgs.callPackage ./acmregister { };
	acm-nixie = pkgs.callPackage ./acm-nixie { };
	caddy = pkgs.callPackage ./caddy { };
	sendlimiter = pkgs.callPackage ./sendlimiter { };
	sysmet = pkgs.callPackage ./sysmet { };
	dischord = pkgs.callPackage ./dischord { };
	discord-ical-reminder = pkgs.callPackage ./discord-ical-reminder { };
	discord-ical-srv = pkgs.callPackage ./discord-ical-srv { };

	# Java
	triggers = pkgs.callPackage ./triggers {};

	# Deno
	pomo = pkgs.callPackage ./pomo { };
}
