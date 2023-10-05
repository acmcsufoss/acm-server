{ stdenv, jre, writeTextFile }:

let
	pkgutil = import <acm-aws/nix/pkgutil.nix>;
in

{
	pname,
	version ? pkgutil.version jar,
	jar,
	jre ? jre,
	meta ? {},
	...
}@args:

writeTextFile {
	name = "${pname}-${version}";
	text = "#!/bin/sh\nexec ${jre}/bin/java -jar ${jar} \"\$@\"";	
	executable = true;
	destination = "/bin/${pname}";
	meta = meta // { noNixUpdate = true; };
}
