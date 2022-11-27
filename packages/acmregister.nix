{ buildGo119Module, fetchFromGitHub, lib }:

let src = (import ../nix/sources.nix).acmregister;

in buildGo119Module {
	pname = "acmregister";
	version = builtins.substring 0 7 src.rev;
	inherit src;
	vendorSha256 = "sha256-hWummvDn2sfg/7yj35+qeGSJb31DZmIA4NTU35CLF3I=";

	# GOWORK is incompatible with vendorSha256.
	GOWORK = "off";
	subPackages = [ "." ];
}
