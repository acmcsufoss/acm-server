{ config, pkgs, lib, ... }:

let sources = import ../nix/sources.nix { inherit pkgs; };

in {
	imports = [
		./caddy/caddy.nix
		./sysmet/sysmet.nix
	];

	nixpkgs.overlays = import ../nix/overlays.nix;
}
