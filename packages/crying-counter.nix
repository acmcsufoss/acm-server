{ lib, stdenv, writeShellScript, makeWrapper, jre, gradle_7 }:

stdenv.mkDerivation rec {
	name = "crying-counter";
	src = (import ../nix/sources.nix).crying-counter;

	nativeBuildInputs = [ makeWrapper gradle_7 ];

	buildPhase = ''
		export GRADLE_USER_HOME=$(mktemp -d)
		gradle --no-daemon build
	'';

	installPhase = ''
		mkdir -p $out/share/java
		cp *.jar $out/share/java/

		mkdir -p $out/bin
		cp ${run} $out/bin/crying-counter
	'';

	run = writeShellScript "crying-counter" ''
		# Hack to self-reference the derivation.
		src="''${BASH_SOURCE[0]}"
		dir="''${src%/*}"
		exec ${jre}/bin/java -jar "$dir/../share/java/"*.jar
	'';

	outputHashAlgo = "sha256";
	outputHashMode = "recursive";
	outputHash = "sha256:1967lv93b795nndx4y1c6k1lwislyax8bipvkw5gvjvz87zlhwpj";
}
