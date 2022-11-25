{ lib, stdenv, makeWrapper, gradle_7 }:

let name = "crying-counter";
	src = (import ../../nix/sources.nix).crying-counter;

in stdenv.mkDerivation {
	inherit name src;
	nativeBuildInputs = [ makeWrapper gradle_7 ];

	buildPhase = ''
		export GRADLE_USER_HOME=$(mktemp -d)
		gradle --no-daemon build
	'';

	installPhase = ''
		mkdir -p $out/share/java
		cp build/libs/*.jar $out/share/java/
	'';

	outputHashAlgo = "sha256";
	outputHashMode = "recursive";
	outputHash = "sha256:0n2yd1s5l0zmlybdb0lji4hx60f02dnbya2yfilpw5gf836pmqa9";
}
