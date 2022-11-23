{ lib, stdenv, makeWrapper, maven }:

let name = "crying-counter";
	src = (import ../../nix/sources.nix).crying-counter;

in stdenv.mkDerivation {
	inherit name src;

	buildInputs = [ maven ];
	nativeBuildInputs = [ makeWrapper ];

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
	outputHash = "0cd1qn9gw1fvzl1xfqa5767sf78kwwfgbdxjszh37byxwshrk5dg";
}
