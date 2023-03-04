{ buildGoModule, fetchFromGitHub, lib, stdenv }:

let pkgutil = import <acm-aws/nix/pkgutil.nix>;
in

buildGoModule rec {
	pname = "sysmet";
	version = pkgutil.version src;
	src = (import <acm-aws/nix/sources.nix>).sysmet;
	vendorSha256 = "sha256:11xqr301fjjx9685svap6ymz61q4li426jn69h9mfrzg16qzr0yv";
}
