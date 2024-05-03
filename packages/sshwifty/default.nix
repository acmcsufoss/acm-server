{ pkgs }:

let
	version = "0.3.9-beta-release-prebuild";
	url = "https://github.com/nirui/sshwifty/releases/download/0.3.9-beta-release-prebuild/sshwifty_0.3.9-beta-release_linux_amd64.tar.gz";
	src = pkgs.fetchzip {
		inherit url;
		sha256 = "sha256-M7SX3nec9LVlII0iPb3udkUY/ESh6EZaW2U2fjhZAiE=";
		stripRoot = false;
	};
in

pkgs.runCommandLocal "sshwifty" {
	nativeBuildInputs = with pkgs; [
		autoPatchelfHook
	];
	meta = {
		mainProgram = "sshwifty";
	};
} ''
	mkdir -p $out/bin
	ln -s ${src}/sshwifty_linux_amd64 $out/bin/sshwifty
''
