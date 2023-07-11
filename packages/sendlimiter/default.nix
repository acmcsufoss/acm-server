{ buildGo119Module, fetchFromGitHub, lib }:

buildGo119Module rec {
	pname = "sendlimiter";
	version = builtins.substring 0 7 src.rev;

	src = (import <acm-aws/nix/sources.nix>).sendlimiter;
	vendorSha256 = "sha256-2hrzIJU8ILove+XWkqdp9TtrtV3lJhdxKhhnuBctxP4=";

	# GOWORK is incompatible with vendorSha256.
	GOWORK = "off";
	subPackages = [ "." ];
}
