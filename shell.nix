{
	pkgs ? import <nixpkgs> {
		overlays = [
		];
	}
}:

pkgs.mkShell {
	buildInputs = with pkgs; [
		terraform
		awscli2
		nix-update
		niv
		git
		git-crypt
		yamllint
	];

	shellHook = ''
		# https://stackoverflow.com/questions/61600333/nix-shell-how-to-load-environment-variables-from-env-file
		set -a
		source .env
		set +a
	'';
}
