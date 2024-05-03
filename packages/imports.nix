{ config, pkgs, lib, ... }:

let sources = import <acm-aws/nix/sources.nix> { };

in {
	imports = [
		./caddy/caddy.nix
		./sysmet/sysmet.nix
		./sshwifty/service.nix
		./dischord/service.nix
		./christmasd/service.nix
	];

	nixpkgs.overlays = import <acm-aws/nix/overlays.nix>;
}
