{ lib, buildGoModule }:

let
	sources = import <acm-aws/nix/sources.nix>;
	pkgutil = import <acm-aws/nix/pkgutil.nix>;
in

buildGoModule rec {
	pname = "christmasd";

	src = sources.christmasd;
	version = pkgutil.version src;

	vendorHash = "sha256-BSE6uZISZGF09S40b/q7owmsOVDvoJVg65Msd7ExM1U=";

	subPackages = [
		"cmd/christmasd"
		"cmd/christmasd-test"
	];
}
