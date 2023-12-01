{ lib, buildDenoPackage }:

buildDenoPackage rec {
	pname = "pomo";
	src = (import <acm-aws/nix/sources.nix>).pomo;
	entrypoint = "server/main.ts";
	outputHash = "sha256-+nz8sQWrz7Rl6eMYdUbRPSP158qL0uFXA1JV5Iy0wx4";
}
