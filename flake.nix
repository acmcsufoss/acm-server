{
	description = "Flake for acm-aws";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=50aa30a13c4ab5e7ba282da460a3e3d44e9d0eb3";

		flake-utils.url = "github:numtide/flake-utils";

		gomod2nix.url = "github:nix-community/gomod2nix";
		gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
		gomod2nix.inputs.flake-utils.follows = "flake-utils";

		poetry2nix.url = "github:nix-community/poetry2nix";
		poetry2nix.inputs.nixpkgs.follows = "nixpkgs";
		poetry2nix.inputs.flake-utils.follows = "flake-utils";

		nix-npm-buildpackage.url = "github:serokell/nix-npm-buildpackage";
		nix-npm-buildpackage.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = {
		self,
		nixpkgs,
		flake-utils,
		gomod2nix,
		poetry2nix,
		nix-npm-buildpackage,
	}@inputs:

	flake-utils.lib.eachDefaultSystem (system:
		let
			pkgs = nixpkgs.legacyPackages.${system};
			overlays = self.overlays.${system};
		in
		{
			overlays = {
				# Overlay for the build tools that our packages use.
				buildTools = final: prev: {
					#
					# Build tools
					#
					inherit (gomod2nix.legacyPackages.${system})
						mkGoEnv buildGoApplication;
					inherit (poetry2nix.lib.mkPoetry2Nix { pkgs = prev; })
						mkPoetryApplication;
					inherit (nix-npm-buildpackage.legacyPackages.${system})
						buildNpmPackage
						buildYarnPackage;
					buildDenoPackage = final.callPackage ./nix/packaging/deno.nix { };
					buildJavaPackage = final.callPackage ./nix/packaging/java.nix { };
					buildGradlePackage = final.callPackage ./nix/packaging/gradle.nix { };
					buildPoetryPackage = final.callPackage ./nix/packaging/poetry.nix { };

					#
					# Miscellanous tools
					#
					nix-update = final.callPackage ./nix/nix-update.nix { };

					#
					# Miscellanous utility derivations
					#
					pkgutil = final.callPackage ./nix/pkgutil.nix { };
					sources = import ./nix/sources.nix {
						inherit system;
						pkgs = prev;
					};
				};
				# Overlay adding our own packages.
				default = final: prev: self.packages.${system};
			};

			packages = import ./packages {
				pkgs = nixpkgs.legacyPackages.${system}.extend (overlays.buildTools);
			};

			nixosConfigurations = {
				cirno = nixpkgs.lib.nixosSystem {
					system = "x86_64-linux";
					modules = [
						({ ... }: { nixpkgs.overlays = [ overlays.default ]; })
						./servers/base.nix
						./servers/cirno/configuration.nix
					];
					specialArgs = inputs // { inherit self; };
				};
				cs306 = nixpkgs.lib.nixosSystem {
					system = "x86_64-linux";
					modules = [
						({ ... }: { nixpkgs.overlays = [ overlays.default ]; })
						./servers/base.nix
						./servers/cs306/configuration.nix
					];
					specialArgs = inputs // { inherit self; };
				};
			};
		}
	);
}
