{ fetchFromGitHub, makeWrapper, lib, stdenv,
  buildGoModule, ffmpeg, youtube-dl }:

let src = (import ../../nix/sources.nix).dischord;

	PATH = [ ffmpeg youtube-dl ];

in buildGoModule {
	pname = "dischord";
	version = builtins.substring 0 7 src.rev;

	inherit src;
	vendorSha256 = "sha256:12y3gqvprfzqdhfvqhz4pw45bv7wl0lbwa8ijfshdij28ly6l6x3";
	subPackages = [ "cmd/dischord" ];

	nativeBuildInputs = [ makeWrapper ];
	postInstall = ''
		wrapProgram $out/bin/dischord --prefix PATH : ${lib.makeBinPath PATH}
	'';
}
