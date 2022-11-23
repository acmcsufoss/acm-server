let sources = import ./sources.nix;

in import sources.nixpkgs {
	overlays = [
		(import "${sources.gomod2nix}/overlay.nix")
		(self: super: {
			nix-update = super.nix-update.overrideAttrs (old: {
				src = sources.diamondburned_nix-update;
			});
		})
	];
}
