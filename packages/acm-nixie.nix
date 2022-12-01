{ buildGo119Module, fetchFromGitHub, lib }:

let src = (import ../nix/sources.nix).acm-nixie;

in buildGo119Module {
	pname = "acm-nixie";
	version = builtins.substring 0 7 src.rev;
	inherit src;
	vendorSha256 = "sha256:17sskd2bmxfkysxd5d33xnbs8qvaml5ng97d1z5i01idhk7nydk4";
	subPackages = [ "." ];
}
