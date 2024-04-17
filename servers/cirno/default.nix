{ nixpkgs, ... }@inputs:

nixpkgs.lib.nixosSystem {
	system = "x86_64-linux";
	modules = [ ./servers/cirno/configuration.nix ];
	specialArgs = inputs;
}
