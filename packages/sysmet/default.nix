{ buildGoModule, fetchFromGitHub, lib, stdenv }:

buildGoModule {
	pname = "sysmet";
	version = "main";
	src = (import ../../nix/sources.nix).sysmet;
	vendorSha256 = "sha256:0cibxp3zm15bc1w0zqgqqg7xv6wgj9lcp8rwah53y6dgqkznxq79";
}
