{ stdenv, jre, writeShellScriptBin }:

let
	pkgutil = import <acm-aws/nix/pkgutil.nix>;
in

{
	pname,
	version ? pkgutil.version jar,
	jar,
	jre ? jre,
	...
}@args:

writeShellScriptBin pname ''
	exec ${jre}/bin/java -jar ${jar} "$@"
''
