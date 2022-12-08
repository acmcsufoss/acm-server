{ fetchFromGitHub, makeWrapper, lib, stdenv,
  buildGoModule, ffmpeg, yt-dlp }:

let src = (import ../../nix/sources.nix).dischord;

	PATH = [ ffmpeg yt-dlp ];

in buildGoModule {
	pname = "dischord";
	version = builtins.substring 0 7 src.rev;

	inherit src;
	vendorSha256 = "sha256:12y3gqvprfzqdhfvqhz4pw45bv7wl0lbwa8ijfshdij28ly6l6x3";
	subPackages = [ "cmd/dischord" ];

	postPatch = ''
		ytExtractor='extractor.AddExtractor("youtube", &Extractor{})'
		sed -i "s|$ytExtractor|// &|" $(find . -name '*.go')
	'';

	nativeBuildInputs = [ makeWrapper ];
	postInstall = ''
		wrapProgram $out/bin/dischord --prefix PATH : ${lib.makeBinPath PATH}
	'';
}
