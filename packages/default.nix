{ pkgs ? import <nixpkgs> {} }:

{
	acmregister = pkgs.callPackage ./acmregister.nix { };
	acm-nixie = pkgs.callPackage ./acm-nixie.nix { };
	crying-counter = pkgs.callPackage ./crying-counter { };
	crying-counter-bin = pkgs.callPackage ./crying-counter/bin.nix { };
	sysmet = pkgs.callPackage ./sysmet { };
	caddy = pkgs.callPackage ./caddy { };
}
