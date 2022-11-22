{ buildGoModule, fetchFromGitHub, lib, stdenv }:

buildGoModule {
	pname = "sysmet";
	version = "main";
	src = (import ../../nix/sources.nix).sysmet;
	vendorSha256 = "sha256:11xqr301fjjx9685svap6ymz61q4li426jn69h9mfrzg16qzr0yv";
}
