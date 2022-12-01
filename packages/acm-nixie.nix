{ buildGo119Module, fetchFromGitHub, lib }:

let src = (import ../nix/sources.nix).acm-nixie;

in buildGo119Module {
	pname = "acm-nixie";
	version = builtins.substring 0 7 src.rev;
	inherit src;
	vendorSha256 = "sha256:1l6gpngrjasmfyh2x6rzr1czzasfd6dks2vj8pq6l5i3w393xfdf";
	subPackages = [ "." ];
}
