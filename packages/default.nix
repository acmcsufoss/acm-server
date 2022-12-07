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
	crying-counter-bin = pkgs.callPackage ./crying-counter/bin.nix {
		inherit (self) crying-counter;
	};
};

in self
