{ config, pkgs, lib, ... }:

let sources = import "${builtins.getEnv "ROOT"}/nix/sources.nix" { inherit pkgs; };

in {
	imports = [
		./caddy/caddy.nix
		./sysmet/sysmet.nix
		./dischord/service.nix
	];

	nixpkgs.overlays = import "${builtins.getEnv "ROOT"}/nix/overlays.nix";
}
