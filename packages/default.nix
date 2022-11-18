{ pkgs ? import <nixpkgs> {} }:

{
	acmregister = pkgs.callPackage ./acmregister.nix { };
	caddy = pkgs.callPackage ./caddy { };
}
