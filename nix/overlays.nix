let sources = import ./sources.nix;
	nix-npm-buildpackage = self: super:
		let pkg = super.callPackage sources.nix-npm-buildpackage { };
		in {
			inherit (pkg) buildNpmPackage buildYarnPackage;
		};

in [
	(import "${sources.gomod2nix}/overlay.nix")
	(nix-npm-buildpackage)
	(self: super: {
		buildDenoPackage = self.callPackage ./packaging/deno.nix { };
		buildGradlePackage = self.callPackage ./packaging/gradle.nix { };
	})
	(self: super: {
		nix-update = super.nix-update.overrideAttrs (old: {
			src = sources.diamondburned_nix-update;
		});
	})
	(self: super: import ../packages { pkgs = self; })
]
