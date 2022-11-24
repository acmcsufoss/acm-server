{ pkgs ? import ./nix/nixpkgs.nix }:

pkgs.mkShell {
	name = "acm-aws-shell";
	buildInputs = import ./nix/shell-pkgs.nix;
}
