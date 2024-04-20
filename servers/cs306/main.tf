variable "ssh_private_key_file" {
	description = "The path to the private key file to use for SSH"
	type = string
}

variable "host" {
	description = "The host to deploy to"
	type = string
}

module "deployment" {
	source = "github.com/tweag/terraform-nixos//deploy_nixos?ref=646cacb12439ca477c05315a7bfd49e9832bc4e3"
	nixos_config = "cs306"
	flake = true
	target_host = "${var.host}"
	ssh_private_key_file = var.ssh_private_key_file
	ssh_agent = false
	hermetic = true
	build_on_target = false
}
