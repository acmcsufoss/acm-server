self: super:

let pkgutil = import <acm-aws/nix/pkgutil.nix>;
in

{
	buildDenoPackage =
		{
			name ? "${pname}-${version}",
			pname,
			version ? pkgutil.version src,
			src,
			entrypoint,
			outputHash,
			...
		}@args:

		super.runCommand name (args // {
			inherit src entrypoint outputHash;
			outputHashMode = "recursive";

			nativeBuildInputs = with super; [
				deno
				makeWrapper
			];

			# Wrapper script to run with the right DENO_DIR environment variable.
			# This allows dynamicUser to work.
			wrapper = super.writeShellScript "${pname}-wrapper" ''
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
		'';

	buildGradlePackage =
		{
			pname,
			src,
			version ? pkgutil.version src,
			outputHash,
			jre ? self.jre,
			gradle ? self.gradle_7,
			...
		}@args:

		self.stdenv.mkDerivation (args // rec {
			inherit pname src version outputHash;
			outputHashMode = "recursive";

			nativeBuildInputs = with super; [
				makeWrapper
				gradle
			];

			buildPhase = ''
				export GRADLE_USER_HOME=$(mktemp -d)
				gradle --no-daemon build
			'';

			installPhase = ''
				mkdir -p $out/share/java
				cp *.jar $out/share/java/

				mkdir -p $out/bin
				cp ${run} $out/bin/${pname}
			'';

			run = super.writeShellScript "build-${pname}" ''
				# Hack to self-reference the derivation.
				src="''${BASH_SOURCE[0]}"
				dir="''${src%/*}"
				exec ${jre}/bin/java -jar "$dir/../share/java/"*.jar
			'';
		});
}
