{ lib, buildDenoPackage }:

buildDenoPackage rec {
	pname = "pomo";
	src = (import <acm-aws/nix/sources.nix>).pomo;
	entrypoint = "server/main.ts";
	outputHash = "sha256-wRASRK4KLuRA/WRgJunFICTFKjFw35LAW00wjdcAsJw=";
}
