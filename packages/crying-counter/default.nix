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
	outputHash = "sha256:1qh443p21rcxk6633k2vh98hppzsby5hwzrxjr2nfk50q92svs28";
}
