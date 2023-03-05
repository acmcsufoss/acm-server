{ stdenv, jre, makeWrapper, gradle_7, perl, git, writeText, runtimeShell, tree }:

let pkgutil = import <acm-aws/nix/pkgutil.nix>;
in

{
	pname,
	src,
	version ? pkgutil.version src,
	patches ? [],
	nativeBuildInputs ? [],
	depsOverride ? {},
	outputHash,
	jre ? jre,
	gradle ? gradle_7,
	...
}@args:

let deps = stdenv.mkDerivation ({
		name = "${pname}-deps";
		inherit src patches;

		nativeBuildInputs = [ gradle perl git ];

		buildPhase = ''
			export GRADLE_USER_HOME=$(mktemp -d)
			gradle --no-daemon build
		'';

		installPhase = ''
			${tree}/bin/tree $GRADLE_USER_HOME
			# Mavenize dependency paths.
			find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(jar\|pom\)' \
				| perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
				| sh
			${tree}/bin/tree $out
		'';

		inherit outputHash;
		outputHashAlgo = "sha256";
		outputHashMode = "recursive";
	} // depsOverride);

	# Point to our local deps repo
	gradleInit = writeText "init.gradle" ''
		logger.lifecycle 'Replacing Maven repositories with ${deps}...'

		gradle.projectsLoaded {
			rootProject.allprojects {
				buildscript {
					repositories {
						clear()
						maven { url '${deps}' }
					}
				}

				repositories {
					clear()
					maven { url '${deps}' }
				}
			}
		}
	'';
in

stdenv.mkDerivation (args // {
	inherit pname src version;

	nativeBuildInputs = nativeBuildInputs ++ [
		makeWrapper
		gradle
	];

	buildPhase = ''
		runHook preBuild

		export GRADLE_USER_HOME=$(mktemp -d)
		gradle --offline --no-daemon --info --init-script ${gradleInit} build -x test

		runHook postBuild
	'';

	installPhase = ''
		runHook preInstall

		install -D build/libs/${pname}.jar $out/share/java/${pname}.jar
		makeWrappper ${jre}/bin/java $out/bin/${pname} \
			--add-flags "-jar $out/share/java/${pname}.jar"

		runHook postInstall
	'';
})
