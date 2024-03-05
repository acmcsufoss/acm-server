{ buildPoetryPackage, git, runCommandLocal }:

let
	sources = import <acm-aws/nix/sources.nix>;

	src = # sources.crying-counter;
		runCommandLocal "crying-counter-src" {
			src = sources.crying-counter;
			nativeBuildInputs = [ git ];
		} ''
			mkdir -p $out
			cp -ar --no-preserve=mode,ownership $src/* $out
			cd $out
			${git}/bin/git apply ${./0001-fix-imports.patch}
		'';
in

buildPoetryPackage {
	pname = "crying-counter";
	module = "crying_counter.main";
	inherit src;
}
