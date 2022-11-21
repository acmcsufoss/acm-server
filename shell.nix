{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
	name = "acm-aws-shell";
	buildInputs = import ./nix/shell-pkgs.nix;
}
