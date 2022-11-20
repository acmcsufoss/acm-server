{ config, pkgs, lib, ... }:

{
	imports = [
		./caddy/caddy.nix
	];

	nixpkgs.overlays = [
		(self: super: import ../packages { pkgs = super; })
	];
}
