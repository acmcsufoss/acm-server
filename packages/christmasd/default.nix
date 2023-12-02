{ lib, buildGoModule }:

let
	sources = import <acm-aws/nix/sources.nix>;
	pkgutil = import <acm-aws/nix/pkgutil.nix>;
in

buildGoModule rec {
	pname = "christmasd";

	src = sources.christmasd;
	version = pkgutil.version src;

	vendorSha256 = "${lib.fakeSha256}";

	subPackages = [
		"cmd/christmasd"
		"cmd/christmasd-test"
	];
}
