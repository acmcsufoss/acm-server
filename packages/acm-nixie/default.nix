{ buildGo119Module, fetchFromGitHub, lib }:

let pkgutil = import <acm-aws/nix/pkgutil.nix>;
in

buildGo119Module rec {
	pname = "acm-nixie";
	version = pkgutil.version src;

	src = (import <acm-aws/nix/sources.nix>).acm-nixie;
	vendorSha256 = "sha256-fkDpovDJTn0Moj6eIZU+3e4Kp/DGv/KEUPE3+ahmBR4=";

	subPackages = [ "." ];
}
