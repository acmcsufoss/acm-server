{ buildGo119Module, fetchFromGitHub, lib }:

buildGo119Module {
	pname = "acmregister";
	version = "main";
	src = (import ../nix/sources.nix).acmregister;
	vendorSha256 = "sha256-hWummvDn2sfg/7yj35+qeGSJb31DZmIA4NTU35CLF3I=";

	# GOWORK is incompatible with vendorSha256.
	GOWORK = "off";
	subPackages = [ "." ];
}
