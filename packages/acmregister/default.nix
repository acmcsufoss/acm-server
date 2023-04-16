{ buildGo119Module, fetchFromGitHub, lib }:

buildGo119Module rec {
	pname = "acmregister";
	version = builtins.substring 0 7 src.rev;

	src = (import <acm-aws/nix/sources.nix>).acmregister;
	vendorSha256 = "sha256:0mh4awgj91zz81yqvlf12fpvfgsvk7h758vygkfhccdg42giic6h";

	# GOWORK is incompatible with vendorSha256.
	GOWORK = "off";
	subPackages = [ "." ];
}
