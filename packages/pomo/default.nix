{ lib, buildDenoPackage }:

buildDenoPackage rec {
	pname = "pomo";
	src = (import <acm-aws/nix/sources.nix>).pomo;
	entrypoint = "server/main.ts";
	outputHash = "sha256:0gzjvba7iz96798mzzmzgikkvg9kjh5ik6vf96z4wn8if49wkiyr";
}
