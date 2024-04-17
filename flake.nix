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
			overlays = self.overlays.${system};
		in
		{
			devShells = let
				pkgs = import nixpkgs {
					inherit system;
					overlays = [
						overlays.buildTools
					];
					config = {
						# Allow unfree packages for Terraform.
						allowUnfree = true;
					};
				};
			in
			{
				default = pkgs.mkShell {
					name = "acm-aws-shell";

					packages = with pkgs; [
						terraform
						awscli2
						nix-update
						jq
						niv
						git
						git-crypt
						openssl
						yamllint
						expect
						shellcheck
					] ++ [
						# Fix Nix Flake's weird scoping issue.
						pkgs.gomod2nix
					];

					# Enforce purity by unsetting NIX_PATH.
					# This messes up any code that uses Nix channels.
					NIX_PATH = "";
				};
			};

			overlays = {
				# Overlay for the build tools that our packages use.
				buildTools = final: prev: {
					#
					# Build tools
					#
					inherit (gomod2nix.legacyPackages.${system})
						mkGoEnv buildGoApplication gomod2nix;

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
				cirno = self.lib.nixosSystem {
					system = "x86_64-linux";
					configuration = ./servers/cirno/configuration.nix;
				};
				cs306 = self.lib.nixosSystem {
					system = "x86_64-linux";
					configuration = ./servers/cs306/configuration.nix;
				};
			};

			lib = {
				# All nixosConfigurations should have this in their specialArgs.
				nixosArgs = { system }: inputs // {
					# Import Niv sources directly into the arguments for convenience.
					sources = import ./nix/sources.nix {
						inherit system;
						pkgs = nixpkgs.legacyPackages.${system};
					};
					# TODO: migrate away from Nix store-based secrets.
					# See https://github.com/acmcsufoss/acm-aws/issues/34.
					secretsPath = secret: self + "/secrets/" + secret;
				};

				mkNixosSystem = { system, configurationFile }:
					nixpkgs.lib.nixosSystem {
						inherit system;
						modules = [
							./servers/base.nix
							configurationFile
						];
						specialArgs = self.lib.nixosArgs {
							inherit system;
						};
					};
			};
		}
	);
}
