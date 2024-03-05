{ poetry2nix, writeShellScriptBin, python3 }:

let
	pkgutil = import <acm-aws/nix/pkgutil.nix>;
in

{
	name ? "${pname}-${version}",
	pname,
	module,
	version ? pkgutil.version src,
	src,
	meta ? {},
	python ? python3,
	overridePoetryAttrs ? (old: {}),
}:

let
	poetryApplication = (poetry2nix.mkPoetryApplication {
		inherit src python;
		pyproject = "${src}/pyproject.toml";
		poetrylock = "${src}/poetry.lock";
		preferWheels = true;
	}).dependencyEnv.overrideAttrs overridePoetryAttrs;

	script = writeShellScriptBin pname ''
		exec ${poetryApplication}/bin/python3 -m ${module} "$@"
	'';
in

script.overrideAttrs (_: {
	meta = meta // {
		mainProgram = pname;
	};
})
