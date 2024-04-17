{ nixpkgs, ... }@inputs:

nixpkgs.lib.nixosSystem {
	system = "x86_64-linux";
	modules = [ ./servers/cs306/configuration.nix ];
	specialArgs = inputs;
}
