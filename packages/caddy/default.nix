{ stdenv, lib,
  runCommand, writeText,
  buildGo118Module, go, modSha256 ? "",
  version ? "v2.4.3",
  plugins ? [] }:

with lib;

# Filter all strings, but pop off the version string if any.
let imports = concatMapStrings
		(pkg: "\t\t\t_ \"${builtins.elemAt (splitString " " pkg) 0}\"\n")
		plugins;

	# Get only strings that contain a space, since it possibly denotes the
	# version.
	modules = flip concatMapStrings
		(builtins.filter (pkg: hasInfix " " pkg) plugins)
		(module: "${module}\n");

	main = writeText "caddy-main.go" ''
		package main
	
		import (
			caddycmd "github.com/caddyserver/caddy/v2/cmd"

			_ "github.com/caddyserver/caddy/v2/modules/standard"
${imports}
		)

		func main() {
			caddycmd.Main()
		}
	'';

	vendorSha256 = (if (modSha256 != "") then modSha256 else
		"sha256:1b604qbr15vianpmwjdb99wni3ncaa9mgbykijd4nnn254g9gy35"
	);

in buildGo118Module rec {
	name = "caddy";
	inherit version vendorSha256;

	overrideModAttrs = (_: {
		preBuild = "go mod tidy";
		postInstall = "cp go.sum go.mod $out/";
	});

	postConfigure = ''
		cp vendor/go.sum ./
		cp vendor/go.mod ./
	'';

	src = runCommand "caddy-src" {
		buildInputs = [ go ];
	} ''
		export HOME="$TMPDIR"
		export GOPATH="$TMPDIR"

		mkdir $out && cd $out

		go mod init caddy

cat <<'EOF' >> go.mod

require (
	github.com/caddyserver/caddy/v2 ${version}
	${modules}
)

EOF

		cp ${main} main.go
	'';


	meta = with lib; {
		homepage = https://caddyserver.com;
		description = "Fast, cross-platform HTTP/2 web server with automatic HTTPS";
		license = licenses.asl20;
	};
}
