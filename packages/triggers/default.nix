{ lib, callPackage, buildGradlePackage, jre_small }:

buildGradlePackage rec {
	pname = "triggers";
	src = (import <acm-aws/nix/sources.nix>).triggers;
	jre = jre_small;
	outputHash = "sha256:1rw7mph1nrfqb42qw050fszf7m0s4wzqn2rx930l73s0fylvgnsd";
}
