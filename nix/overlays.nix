let
	sources = import ./sources.nix;

	nix-npm-buildpackage = self: super:
		let pkg = super.callPackage sources.nix-npm-buildpackage { };
		in {
			inherit (pkg) buildNpmPackage buildYarnPackage;
		};

	defaultOverlays = [
		(import "${sources.gomod2nix}/overlay.nix")
		(nix-npm-buildpackage)
	];

	newer = import sources.nixpkgs_newer {
		overlays = defaultOverlays;
	};

in defaultOverlays ++ [
	(self: super: {
		poetry2nix = import sources.poetry2nix {
			pkgs = self;
		};
	})
	(self: super: {
		buildDenoPackage = self.callPackage ./packaging/deno.nix { };
		buildJavaPackage = self.callPackage ./packaging/java.nix { };
		buildGradlePackage = self.callPackage ./packaging/gradle.nix { };
		buildPoetryPackage = self.callPackage ./packaging/poetry.nix { };
	})
	(self: super: {
		nix-update = super.callPackage ./nix-update.nix { };
	})
	(self: super: import ../packages { pkgs = self; })
]
