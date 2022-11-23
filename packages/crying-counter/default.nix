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
	outputHash = "0ig53l6k5bwf28wpz7s5fdc6xdkmiwy2s66vmgaf0mmh9njhpgf6";
}
