{ buildGoModule, fetchFromGitHub, lib, stdenv }:

let src = (import ../../nix/sources.nix).sysmet;

in buildGoModule {
	pname = "sysmet";
	version = builtins.substring 0 7 src.rev;
	inherit src;
	vendorSha256 = "sha256:11xqr301fjjx9685svap6ymz61q4li426jn69h9mfrzg16qzr0yv";
}
