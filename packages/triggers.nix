{ lib, stdenv, writeShellScript, makeWrapper, jre, gradle_7 }:

stdenv.mkDerivation rec {
	name = "triggers";
	src = (import ../nix/sources.nix).${name};

	nativeBuildInputs = [ makeWrapper gradle_7 ];

	buildPhase = ''
		export GRADLE_USER_HOME=$(mktemp -d)
		gradle --no-daemon build
	'';

	installPhase = ''
		mkdir -p $out/share/java
		cp *.jar $out/share/java/

		mkdir -p $out/bin
		cp ${run} $out/bin/${name}
	'';

	run = writeShellScript name ''
		# Hack to self-reference the derivation.
		src="''${BASH_SOURCE[0]}"
		dir="''${src%/*}"
		exec ${jre}/bin/java -jar "$dir/../share/java/"*.jar
	'';

	outputHashAlgo = "sha256";
	outputHashMode = "recursive";
	outputHash = "sha256:1xn8gsdk1bk188hcsmkxg1gsj6mqlq8bbk6dlvacl1ljincypisw";
}
