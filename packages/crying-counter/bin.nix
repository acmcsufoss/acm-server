{ lib, stdenv, makeWrapper, jre, crying-counter }:

stdenv.mkDerivation {
	name = "crying-counter-bin";
	unpackPhase = "true"; # no source

	buildInputs = [ crying-counter ];
	nativeBuildInputs = [ jre makeWrapper ];

	installPhase = ''
		mkdir -p $out/bin

		classpath=""
		classpath+=$(printf ":%s" ${crying-counter}/share/java/*.jar)
		classpath+=$(find ${crying-counter}/repository -name "*.jar" -printf ':%h/%f');

		makeWrapper ${jre}/bin/java $out/bin/crying-counter \
			--add-flags "-classpath ''${classpath#:}" \
			--add-flags "Main"
	'';
}
