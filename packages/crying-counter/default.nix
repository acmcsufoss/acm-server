{ buildPoetryPackage, git, runCommandLocal }:

let
	sources = import <acm-aws/nix/sources.nix>;
in

buildPoetryPackage {
	pname = "crying-counter";
	module = "crying_counter.main";
	src = sources.crying-counter;
}
