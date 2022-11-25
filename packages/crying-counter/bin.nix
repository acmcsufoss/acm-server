{ lib, stdenv, makeWrapper, jre_minimal, crying-counter }:

stdenv.mkDerivation {
	name = "crying-counter-bin";
	unpackPhase = "true"; # no source

	buildInputs = [ crying-counter ];
	nativeBuildInputs = [ makeWrapper ];

	installPhase = ''
		mkdir -p $out/bin
		mkdir -p $out/share
		ln -s ${crying-counter}/share/java $out/share/java

		jars=( $out/share/java/*.jar )
		jar="''${jars[0]}"

		makeWrapper ${jre_minimal}/bin/java $out/bin/crying-counter \
			--add-flags "-jar $jar"
	'';
}
