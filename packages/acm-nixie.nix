{ buildGo119Module, fetchFromGitHub, lib }:

buildGo119Module {
	pname = "acm-nixie";
	version = "main";
	src = (import ../nix/sources.nix).acm-nixie;
	vendorSha256 = "sha256-YwkotdQI/uSrdOjB2RKm7UQF77qXUPK4eulmOLQzwCU=";
	subPackages = [ "." ];
}
