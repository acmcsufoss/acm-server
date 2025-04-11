variable "ssh_private_key_file" {
	description = "The path to the private key file to use for SSH"
	type = string
}

variable "host" {
	description = "The host to use, otherwise the AWS public IP is used"
	type = string
	default = null
}

module "deployment" {
	source = "git::https://github.com/Gabriella439/terraform-nixos-ng.git//nixos?ref=af1a0af57287851f957be2b524fcdc008a21d9ae"
	flake = ".#cs306-thinkcentre-1"
	host = "root@${var.host}"
	ssh_options = "-i ${var.ssh_private_key_file} -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
}
