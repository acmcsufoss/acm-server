variable "ssh_private_key_file" {
	description = "The path to the private key file to use for SSH"
	type = string
}

module "deployment" {
	source = "git::https://github.com/diamondburned/terraform-nixos.git//deploy_nixos?ref=9d26ace355b2ed7d64a253b11ab12395a1395030"
	nixos_config = "${path.module}"
	target_host = "cs306"
	ssh_private_key_file = var.ssh_private_key_file
	ssh_agent = false
	hermetic = true
	build_on_target = false
}
