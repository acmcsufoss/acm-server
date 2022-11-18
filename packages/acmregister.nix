{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule {
	pname = "acmregister";
	version = "d85e4b1";
	src = (import ../nix/sources.nix).acmregister;
	vendorSha256 = "sha256-hWummvDn2sfg/7yj35+qeGSJb31DZmIA4NTU35CLF3I=";

	# GOWORK is incompatible with vendorSha256.
	GOWORK = "off";
	subPackages = [ "." ];
}
