{ config, lib, pkgs, ... }:

let
	podmanServiceName = containerName: "podman-" + containerName;
in

{
	virtualisation.oci-containers =
		let
			# Use a Nix-locked Ubuntu image for caching, not for reproducibility.
			# Forget about reproducibility, it's not possible with Docker.
			# See https://nixos.org/manual/nixpkgs/stable/#ssec-pkgs-dockerTools-fetchFromRegistry.
			ubuntuImage = pkgs.dockerTools.pullImage {
				imageName = "ubuntu";
				imageDigest = "sha256:bcc511d82482900604524a8e8d64bf4c53b2461868dac55f4d04d660e61983cb";
				finalImageName = "ubuntu";
				finalImageTag = "latest";
				sha256 = "sha256-qjUOR8QKzJVwMkUyn9ZuHLnYPA0PKupKnThuijo4LdM=";
				os = "linux";
				arch = "x86_64";
			};

			cmdArgs = [];

			# See https://nixos.org/manual/nixpkgs/stable/#ssec-pkgs-dockerTools-buildLayeredImage.
			imageFile = pkgs.dockerTools.buildLayeredImage {
				name = "experimental-discord-bot-image";
				tag = "latest";
				enableFakechroot = true;
				fromImage = ubuntuImage;
				contents = pkgs.writeShellScriptBin "experimental-discord-bot" ''
					echo "Initializing Ubuntu..."
					apt update
					apt install -y git golang

					echo "Downloading Discord bot..."
					git clone https://libdb.so/arikawa
					cd arikawa/0-examples/commands-hybrid

					echo "Ensuring that the contents are proper..."
					ls

					echo "Building the bot..."
					go build -v

					echo "Running the bot..."
					exec ./commands-hybrid
				'';
				config.Cmd = [ "/bin/experimental-discord-bot" ] ++ cmdArgs;
			};
		in
		{
			backend = "podman";
			containers = {
				"experimental-discord-bot" = {
					autoStart = true;
					environment = {
						TEST_ENV1 = "test1";
						TEST_ENV2 = "test2";
					};
					ports = [
						"127.0.0.1:48765:80"
					];
					image = "experimental-discord-bot-image:latest";
					inherit imageFile;
				};
			};
		};

	systemd.services.${podmanServiceName "experimental-discord-bot"} = {
		serviceConfig = {
			Restart = "on-failure";
			RestartSec = "5s";
		};
		startLimitBurst = 3;
		startLimitIntervalSec = 5 * 60; # 5 minutes
	};
}
