{ config, lib, pkgs, ... }:

{
	imports = [
		./_telemetry.nix
		./_acm.nix
	];

	services.managed.enable = true;
}
