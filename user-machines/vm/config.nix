{ pkgs }:

with pkgs.lib;
with builtins;

let
	div = a: b: floor a / b;
	mod = a: b: a - (b * (div a b));

	hostOrderToIP = hostOrder: concatStringsSep "." [
		# (toString (hostOrder / 256 / 256 / 256))
		# (toString (hostOrder / 256 / 256 % 256))
		# (toString (hostOrder / 256 % 256))
		# (toString (hostOrder % 256))
		(toString (div (div (div hostOrder 256) 256) 256))
		(toString (mod (div (div hostOrder 256) 256) 256))
		(toString (mod (div hostOrder 256) 256))
		(toString (mod hostOrder 256))
	];

	mkCloudInitImage = pkgs.callPackage ./ubuntu-cloud-init.nix { };
in

{
	lib = {
		inherit
			hostOrderToIP
			mkCloudInitImage;
	};

	ips = rec {
		start = {
			ip = "192.168.168.2";
			order = 3232278530;
		};
		end = {
			ip = "192.168.175.254";
			order = 3232280574;
		};
		# count is the number of IPs between the start and end IPs, inclusive.
		count = end.order - start.order + 1;
		# range is a list of all the order numbers between the start and end IPs.
		range = pkgs.lib.range start.order end.order;
		# ipFromOffset returns the IP address that is offset away from the start IP.
		ipFromOffset = offset: hostOrderToIP (start.order + offset);
	};

	ubuntu = rec {
		# NOTE: DO NOT REMOVE ITEMS IN THE IMAGE LIST. YOU MUST ONLY APPEND TO IT.
		# libvirt requires all images to be present for its backing store, so it is not safe to delete
		# existing images when updating the list.
		images = [
			(pkgs.fetchurl {
				url = "https://isos.acmcsuf.com/ubuntu/2024-05-02/noble-server-cloudimg-amd64.img";
				sha256 = "32a9d30d18803da72f5936cf2b7b9efcb4d0bb63c67933f17e3bdfd1751de3f3";
				passthru.format = "qcow2";
			})
		];

		# Use the last image in the list as the default image.
		image = last images;
	};
}
