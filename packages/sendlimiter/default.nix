{ buildGo119Module, fetchFromGitHub, lib }:

buildGo119Module rec {
	pname = "sendlimiter";
	version = builtins.substring 0 7 src.rev;

	src = (import <acm-aws/nix/sources.nix>).sendlimiter;
	vendorSha256 = "sha256-jvpgUDN6ds0An8qDy7RsR3zF2tlU1nczP/TT5oNr098=";

	# GOWORK is incompatible with vendorSha256.
	GOWORK = "off";
	subPackages = [ "." ];
}
