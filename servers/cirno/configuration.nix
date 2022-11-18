{ config, lib, pkgs, ... }:

{
	imports = [
		<nixpkgs/nixos/modules/virtualisation/amazon-image.nix>
	];
}
