{ buildGo119Module, fetchFromGitHub, lib }:

buildGo119Module rec {
	pname = "acmregister";
	version = builtins.substring 0 7 src.rev;

	src = (import "${builtins.getEnv "ROOT"}/nix/sources.nix").acmregister;
	vendorSha256 = "sha256-hWummvDn2sfg/7yj35+qeGSJb31DZmIA4NTU35CLF3I=";

	# GOWORK is incompatible with vendorSha256.
	GOWORK = "off";
	subPackages = [ "." ];
}
