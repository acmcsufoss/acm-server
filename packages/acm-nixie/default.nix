{ buildGo119Module, fetchFromGitHub, lib }:

let pkgutil = import "${builtins.getEnv "ROOT"}/nix/pkgutil.nix";
in

buildGo119Module rec {
	pname = "acm-nixie";
	version = pkgutil.version src;

	src = (import "${builtins.getEnv "ROOT"}/nix/sources.nix").acm-nixie;
	vendorSha256 = "sha256:1l6gpngrjasmfyh2x6rzr1czzasfd6dks2vj8pq6l5i3w393xfdf";

	subPackages = [ "." ];
}
