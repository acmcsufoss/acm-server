{
	pkgs ? import <nixpkgs> {
		overlays = [
		];
	}
}:

pkgs.mkShell {
	buildInputs = (import ./nix/dev_pkgs.nix pkgs) ++ (with pkgs; []);

	shellHook = ''
		# https://stackoverflow.com/questions/61600333/nix-shell-how-to-load-environment-variables-from-env-file
		set -a
		source .env
		set +a
	'';
}
