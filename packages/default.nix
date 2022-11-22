{ pkgs ? import <nixpkgs> {} }:

{
	acmregister = pkgs.callPackage ./acmregister.nix { };
	acm-nixie = pkgs.callPackage ./acm-nixie.nix { };
	sysmet = pkgs.callPackage ./sysmet { };
	caddy = pkgs.callPackage ./caddy { };
}
