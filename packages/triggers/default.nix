{ lib, callPackage, buildGradlePackage, jre_small }:

buildGradlePackage rec {
	pname = "triggers";
	src = (import <acm-aws/nix/sources.nix>).triggers;
	jre = jre_small;
	outputHash = "sha256:0s9rb110b8ks7mxxb298hlb97l4hgng5gk2nhs5p1sbnr6qr7762";
}
