{ pkgs ? import ./nix/nixpkgs.nix }:

let pkgssrc = (import ./nix/sources.nix).nixpkgs;
in

pkgs.mkShell {
	name = "acm-aws-shell";
	buildInputs = with pkgs; [
		terraform
		awscli2
		rnix-lsp
		nix-update
		niv
		git
		git-crypt
		openssl
		yamllint
		gomod2nix
		expect
		shellcheck
	];

	NIX_PATH = "nixpkgs=${pkgssrc}:acm-aws=${builtins.toString ./.}";
}
