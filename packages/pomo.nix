{ pkgs, lib, deno }:

let src = (import <acm-aws/nix/sources.nix>).pomo;
	version = builtins.substring 0 7 src.rev;

in pkgs.runCommand "pomo-${version}" {
	inherit src;

	nativeBuildInputs = [ deno ];

	outputHash = "sha256:0nwd2rhqrfa8v2nms410f1djxwyb4zc0c3v62m7ic8gvmb5d8h4d";
	outputHashMode = "recursive";
} ''
	export DENO_DIR="$TMPDIR/deno"

	echo "Source:"
	ls $src

	mkdir -p $out/bin
	deno compile -A --output $out/bin/pomo $src/server/main.ts

	ls $out/bin
''
