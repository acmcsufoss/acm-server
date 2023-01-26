{ pkgs ? import ../nix/nixpkgs.nix }:

let self = rec {
	# Go
	acmregister = pkgs.callPackage ./acmregister.nix { };
	acm-nixie = pkgs.callPackage ./acm-nixie.nix { };
	caddy = pkgs.callPackage ./caddy { };
	sysmet = pkgs.callPackage ./sysmet { };
	dischord = pkgs.callPackage ./dischord { };

	# Java
	jre = pkgs.callPackage ./jre { };
	triggers = pkgs.callPackage ./triggers.nix { inherit jre; };
};

in self
