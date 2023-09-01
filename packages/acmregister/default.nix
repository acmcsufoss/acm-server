{ buildGo119Module, fetchFromGitHub, lib }:

buildGo119Module rec {
	pname = "acmregister";
	version = builtins.substring 0 7 src.rev;

	src = (import <acm-aws/nix/sources.nix>).acmregister;
	vendorSha256 = "sha256-PJhMlCNPuiWjq3asL2YP48teoWTIXsojGVvIoQIydeE=";

	# GOWORK is incompatible with vendorSha256.
	GOWORK = "off";
	subPackages = [ "." ];
}
