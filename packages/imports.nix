{ config, pkgs, lib, ... }:

{
	imports = [
		./caddy/caddy.nix
	];
}
