{ config, pkgs, lib, ... }:

let sources = import ../nix/sources.nix { inherit pkgs; };

in {
	imports = [
		./caddy/caddy.nix
		./sysmet/sysmet.nix
	];

	nixpkgs.overlays = [
		(import "${sources.gomod2nix}/overlay.nix")
		(self: super: import ../packages { pkgs = self; })
	];
}
