{
	pkgs,
	cmdArgs ? [],
}:

rec {
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

	# See https://nixos.org/manual/nixpkgs/stable/#ssec-pkgs-dockerTools-buildLayeredImage.
	imageFile = pkgs.dockerTools.buildLayeredImage {
		name = "experimental-discord-bot-image";
		tag = "latest";
		fromImage = ubuntuImage;
		enableFakechroot = true;

		contents = pkgs.writeShellScriptBin "experimental-discord-bot" ''
			echo "Checking for Internet connectivity..."
			wget --spider http://google.com

			echo "Initializing the package manager..."
			apt update
			apt install -y --no-install-recommends \
				ca-certificates \
				curl \
				bash \
				git

			echo "Installing Go..."
			apt install -y golang

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

		config = {
			Entrypoint = [ "/bin/experimental-discord-bot" ] ++ cmdArgs;
		};
	};
}
