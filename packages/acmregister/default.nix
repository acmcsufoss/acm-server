{ buildGo119Module, fetchFromGitHub, lib }:

buildGo119Module rec {
	pname = "acmregister";
	version = builtins.substring 0 7 src.rev;

	src = (import <acm-aws/nix/sources.nix>).acmregister;
	vendorSha256 = "sha256-2hrzIJU8ILqNy+XWkqdp9TtrtV3lJhdxKhhnuBctxP4=";

	# GOWORK is incompatible with vendorSha256.
	GOWORK = "off";
	subPackages = [ "." ];
}
