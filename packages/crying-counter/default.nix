{ lib, stdenv, writeShellScript, makeWrapper, jre_minimal, gradle_7 }:

let
	jre = jre_minimal.override {
		modules = [
			"java.base"
			"java.sql"
			"java.net.http"
			"java.management"
			"jdk.crypto.cryptoki"
			"jdk.crypto.ec"
		];
	};
in
	
stdenv.mkDerivation rec {
	name = "crying-counter";
	src = (import ../../nix/sources.nix).crying-counter;

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
	outputHash = "sha256:12f933qlqj4758sb3vg1p4lz89sn0sik5jgz61ycw4ddnfa6wnff";
}
