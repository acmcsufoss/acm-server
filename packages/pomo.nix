{ pkgs, lib, deno }:

let src = (import ../nix/sources.nix).pomo;
	version = builtins.substring 0 7 src.rev;

in pkgs.runCommand "pomo-${version}" {
	nativeBuildInputs = [ deno ];

	inherit src;
	outputHash = "sha256:${lib.fakeSha256}";
	outputHashMode = "recursive";
} ''
	export DENO_DIR="$TMPDIR/deno"

	echo "Source:"
	ls $src

	mkdir -p $out/bin
	deno compile -A --output $out/bin/pomo $src/server/main.ts

	ls $out/bin
''
