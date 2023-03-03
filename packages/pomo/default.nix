{ lib, buildDenoPackage }:

buildDenoPackage rec {
	pname = "pomo";
	src = (import "${builtins.getEnv "ROOT"}/nix/sources.nix").pomo;
	entrypoint = "server/main.ts";
	outputHash = "sha256:0yqa7n3hpmynmh12fgdm5g0xk1slywj25dnhn7478yavr3fl1rr9";
}
