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

runCommand name (args // {
	inherit (args) src entrypoint outputHash;
	outputHashMode = "recursive";

	nativeBuildInputs = [
		deno
		makeWrapper
	];

	# Wrapper script to run with the right DENO_DIR environment variable.
	# This allows dynamicUser to work.
	wrapper = writeShellScript "${pname}-wrapper" ''
		export TMPDIR="''${TMPDIR:-/tmp}"
		export DENO_DIR="''${DENO_DIR:-$TMPDIR/.deno}"

		binary="$(dirname "''${BASH_SOURCE[0]}")/.${pname}-wrapped"
		exec "$binary" "$@"
	'';
}) ''
	export DENO_DIR="$TMPDIR/deno"
	mkdir -p $out/bin
	deno compile -A --output $out/bin/.${pname}-wrapped "$src/$entrypoint"
	cp $wrapper $out/bin/${pname}
''
