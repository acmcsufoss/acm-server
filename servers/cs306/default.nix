let
	sources = import <acm-aws/nix/sources.nix>;
in

import "${sources.nixpkgs}/nixos" {
	system = "x86_64-linux";
	configuration = import ./configuration.nix;
}
