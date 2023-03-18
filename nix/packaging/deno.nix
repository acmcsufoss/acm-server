{ runCommand, deno, makeWrapper, writeShellScript }:

let pkgutil = import <acm-aws/nix/pkgutil.nix>;
in

{
	name ? "${pname}-${version}",
	pname,
	version ? pkgutil.version src,
	src,
	entrypoint,
	outputHash,
	...
}@args:

let denoPkg = runCommand "${name}-deno-pkg" (args // {
		inherit (args) src entrypoint outputHash;
		outputHashMode = "recursive";
		nativeBuildInputs = [ deno ];
	}) ''
		export DENO_DIR="$TMPDIR/deno"
		mkdir -p $out/bin
		deno compile -A --output $out/bin/${pname} "$src/$entrypoint"
	'';
in

runCommand name {
	nativeBuildInputs = [ makeWrapper ];
	buildInputs = [ denoPkg ];
	passthru = {
		inherit outputHash;
		outputHashMode = "recursive";
	};
} ''
	mkdir -p $out/bin
	makeWrapper ${denoPkg}/bin/${pname} $out/bin/${pname} \
		--set-default DENO_DIR '/tmp/.deno'
''
