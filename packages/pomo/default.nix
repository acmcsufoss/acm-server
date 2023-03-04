{ lib, buildDenoPackage }:

buildDenoPackage rec {
	pname = "pomo";
	src = (import <acm-aws/nix/sources.nix>).pomo;
	entrypoint = "server/main.ts";
	outputHash = "sha256:0bi1hcgd36073h834xa5xwsmz2j3zailknlal7nn6lqnywgf3cz4";
}
