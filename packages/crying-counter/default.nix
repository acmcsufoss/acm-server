{ lib, stdenv, makeWrapper, maven, jre }:

let name = "crying-counter";
	src = (import ../../nix/sources.nix).crying-counter;

in stdenv.mkDerivation {
	inherit name src;

	buildInputs = [ maven ];
	nativeBuildInputs = [ jre makeWrapper ];

	buildPhase = ''
		mvn package -Dmaven.repo.local=$out/repository
		find $out/repository -type f \
			-name \*.lastUpdated -or \
			-name resolver-status.properties -or \
			-name _remote.repositories \
			-delete
	'';

	installPhase = ''
		mkdir -p $out/bin
		mkdir -p $out/share/java

		for f in target/*.jar; do
			install -Dm644 -t $out/share/java "$f"
		done
	'';

	# don't do any fixup
	dontFixup = true;

	outputHashAlgo = "sha256";
	outputHashMode = "recursive";
	outputHash = "sha256-ZlASZZO0EdB4KgKLzR9quRRyN4oHxPXmHoce6Vmutx0=";
}
