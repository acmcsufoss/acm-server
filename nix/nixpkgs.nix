let sources = import ./sources.nix;

in import sources.nixpkgs {
	overlays = [
		(import "${sources.gomod2nix}/overlay.nix")
	];
}
