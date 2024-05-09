{ pkgs ? import ./nix/nixpkgs.nix }:

let
	pkgssrc = (import ./nix/sources.nix).nixpkgs;
in

pkgs.mkShell {
	name = "acm-aws-shell";
	buildInputs = with pkgs; [
		cloud-init
		terraform
		awscli2
		nix-update
		jq
		niv
		git
		git-crypt
		openssl
		gomod2nix
		waypipe
		expect

		# editor tools.
		yamllint
		shellcheck
		nodePackages.bash-language-server
		# rnix-lsp
	];

	shellHook = ''
		set -o allexport
		source .env
		set +o allexport

		export NIX_PATH="$NIX_PATH:nixpkgs=${pkgssrc}:acm-aws=${builtins.toString ./.}";
	'';
}
