{ lib, buildDenoPackage }:

buildDenoPackage rec {
	pname = "pomo";
	src = (import <acm-aws/nix/sources.nix>).pomo;
	entrypoint = "server/main.ts";
	outputHash = "sha256:094znhgg9bdlmr5hpsrkbhrl12lkf2mvn7ws8riy2n7z04dx1dl5";
}
