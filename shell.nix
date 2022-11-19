{
	pkgs ? import <nixpkgs> {
		overlays = [
		];
	}
}:

pkgs.mkShell {
	buildInputs = (import ./nix/dev_pkgs.nix pkgs) ++ (with pkgs; []);
}
