{ lib, stdenv, runCommandLocal, fetchurl }:

let
	version = "0.1.0-alpha3";

	src =
		assert stdenv.isx86_64 && stdenv.isLinux;
		fetchurl {
			url = "https://github.com/jacobtread/Quizler/releases/download/v${version}/quizler-linux";
			sha256 = "sha256-wFvdOcEiw4pO3xgz6NvJBiY7CpKFjFQwgGT2KZRsrrQ=";
		};
in

runCommandLocal "quizler-${version}" {
	inherit version;
	QUIZLER_BIN = "${src}";
} ''
	install -Dm755 $QUIZLER_BIN $out/bin/quizler
''
