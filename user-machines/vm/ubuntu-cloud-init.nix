{ pkgs }:

{
	user,
	user-data ? {},
	meta-data ? {},
	network-config ? {},
}:

let
	extras = {
		inherit
			user-data
			meta-data
			network-config;
	};
in

with pkgs.lib;
with builtins;

# https://cloudinit.readthedocs.io/en/latest/reference/examples.html#including-users-and-groups
let
	lib = pkgs.lib;

	# Add the repo's admin public key.
	# publicKeys = [
	# 	(builtins.readFile ./secrets/ssh/id_ed25519.pub)
	# ];

	hostname = "acm-vm-${user.id}";

	user-data = writeYAML "user-data.yml" ("#cloud-config\n" + (toJSON (
		let
			base = {
				users = [
					(
						{
							name = user.id;
							sudo = "ALL=(ALL) NOPASSWD:ALL";
							shell = "/bin/bash";
							lock_passwd = false;
							plain_text_passwd = user.default_password;
						} //
						(lib.optionalAttrs (user.ssh_public_key != null) {
							ssh_authorized_keys = [ user.ssh_public_key ];
						})
					)
				];
				ssh_pwauth = user.ssh_public_key == null;
				ssh_deletekeys = true;
				package_update = true;
				packages = [
					"htop"
					"curl"
					"git"
				];
				runcmd = [
					# Permanently disable cloud-init after first boot.
					# This permits the user to change anything they want afterwards.
					"touch /etc/cloud/cloud-init.disabled"
				];
			};
		in
			base // (extras.user-data)
	)));

	meta-data = writeYAML "meta-data.yml" (toJSON ({
		instance-id = hostname;
		local-hostname = hostname;
	} // extras.meta-data));

	network-config = writeYAML "network-config.yml" (toJSON ({
	} // extras.network-config));

	writeYAML = name: json: pkgs.runCommandLocal name {
		nativeBuildInputs = with pkgs; [
			yq-go
		];
		JSON_FILE = pkgs.writeText "${name}.yml" json;
	} ''
		yq -P -oy "$JSON_FILE" > $out
	'';

	# Refer to the following link for more information:
	# https://canonical-subiquity.readthedocs-hosted.com/en/latest/howto/autoinstall-quickstart.html#create-an-iso-to-use-as-a-cloud-init-data-source
	image = pkgs.runCommand "${user.id}-cloud-init.iso" {
		nativeBuildInputs = with pkgs; [
			cloud-init
			cloud-utils
		];
		passthru = {
			inherit
				user-data
				meta-data
				network-config;
		};
	} ''
		# TODO:Fix validation
		# cloud-init schema -c "$USERDATA" --annotate

		cloud-localds -N ${network-config} $out ${user-data} ${meta-data}
	'';
in

image
