{ lib, buildDenoPackage }:

buildDenoPackage rec {
	pname = "pomo";
	src = (import <acm-aws/nix/sources.nix>).pomo;
	entrypoint = "server/main.ts";
	outputHash = "sha256-0Xq//RHtJYG5u8qBLmuVh8wzQtpq0r5UOvPQdH7Qzy0=";
}
