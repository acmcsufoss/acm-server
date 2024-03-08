{
	nixpkgs ? (import ./nix/sources.nix).nixpkgs,
	system ? builtins.currentSystem,
}:

# TODO: migrate this to a Flake. The outputs are basically the same!

let
	pkgs = import nixpkgs {
		system = system;
		config.allowUnfree = true;
	};
in

rec {
	packages = import ./packages {
		inherit pkgs;
	};

	nixosConfigurations =
		with pkgs.lib;
		with builtins;
		let
			serverDirs = filterAttrs (name: v: v == "directory") (readDir ./servers);
			servers = mapAttrs (name: _: import (./servers + "/${name}")) serverDirs;
		in
			servers;
}
