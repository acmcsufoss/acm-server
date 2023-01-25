{ pkgs ? import ../nix/nixpkgs.nix }:

let self = {
	# Go
	acmregister = pkgs.callPackage ./acmregister.nix { };
	acm-nixie = pkgs.callPackage ./acm-nixie.nix { };
	caddy = pkgs.callPackage ./caddy { };
	sysmet = pkgs.callPackage ./sysmet { };
	dischord = pkgs.callPackage ./dischord { };

	# Java (Maven)
	crying-counter = pkgs.callPackage ./crying-counter { };
};

in self
