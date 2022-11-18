{ pkgs ? import <nixpkgs> {} }:

{
	acmregister = pkgs.callPackage ./acmregister.nix { };
}
