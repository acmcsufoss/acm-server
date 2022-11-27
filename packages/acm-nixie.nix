{ buildGo119Module, fetchFromGitHub, lib }:

let src = (import ../nix/sources.nix).acm-nixie;

in buildGo119Module {
	pname = "acm-nixie";
	version = builtins.substring 0 7 src.rev;
	inherit src;
	vendorSha256 = "sha256-YwkotdQI/uSrdOjB2RKm7UQF77qXUPK4eulmOLQzwCU=";
	subPackages = [ "." ];
}
