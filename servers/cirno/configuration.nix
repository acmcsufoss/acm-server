{ config, lib, pkgs, ... }:

{
	imports = [
		../base.nix
	];

	services.diamondburned.caddy = {
		enable = true;
		config = builtins.readFile ./secrets/Caddyfile;
		version = "v2.6.2";
		plugins = [
			"github.com/mholt/caddy-webdav c949b32"
			"github.com/mholt/caddy-ratelimit 839066d"
			"github.com/caddy-dns/namecheap 3e59916"
			"github.com/lucas-clemente/quic-go v0.31.0"
			# This fixes some quirky Go module conflict.
			"github.com/antlr/antlr4/runtime/Go/antlr v0.0.0-20220418222510-f25a4f6275ed"
		];
		modSha256 = "sha256-ioPZfzwEp8k/P9NdpgCL9q5/TV9EJo3mWplBfNNTeJs=";
	};

	systemd.services.acmregister = {
		enable = true;
		description = "ACM member registration Discord bot";
		after = [ "network-online.target" ];
		wantedBy = [ "multi-user.target" ];
		environment = import ./secrets/acmregister-env.nix;
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pkgs.acmregister}/bin/acmregister";
		};
	};

	environment.systemPackages = with pkgs; [];
}
