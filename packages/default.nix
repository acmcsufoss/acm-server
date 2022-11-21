{ pkgs ? import <nixpkgs> {} }:

{
	acmregister = pkgs.callPackage ./acmregister.nix { };
	acm-nixie = pkgs.callPackage ./acm-nixie.nix { };
	caddy = pkgs.callPackage ./caddy { };
}
