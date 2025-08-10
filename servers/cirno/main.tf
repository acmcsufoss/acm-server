module "nixos_image" {
	source	= "git::https://github.com/swdunlop/terraform-nixos.git//aws_image_nixos?ref=79219181ded4b7430d3323ec377a7cee11b2ade0"
	release = "21.05"
}

variable "key_name" {
	description = "The name of the keypair to use for the instance"
	type = string
}

variable "ssh_private_key_file" {
	description = "The path to the private key file to use for SSH"
	type = string
}

variable "host" {
	description = "The host to use, otherwise the AWS public IP is used"
	type = string
	default = null
}

locals {
	chosen_address = var.host != null ? var.host : aws_instance.cirno.public_ip
}

resource "aws_security_group" "cirno" {
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = [ "0.0.0.0/0" ]
	}
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = [ "0.0.0.0/0" ]
	}
	ingress {
		from_port = 443
		to_port = 443
		protocol = "tcp"
		cidr_blocks = [ "0.0.0.0/0" ]
	}
	ingress {
		from_port = 443
		to_port = 443
		protocol = "udp"
		cidr_blocks = [ "0.0.0.0/0" ]
	}
	# Allow Tailscale ports.
	ingress {
		from_port = 41641
		to_port = 41641
		protocol = "udp"
		cidr_blocks = [ "0.0.0.0/0" ]
	}
	egress {
		from_port = 0
		to_port	= 0
		protocol = "-1"
		cidr_blocks = [ "0.0.0.0/0" ]
	}
}

resource "aws_instance" "cirno" {
	ami = module.nixos_image.ami
	instance_type = "t2.micro"
	key_name = var.key_name
	security_groups = [ aws_security_group.cirno.name ]

	tags = {
		Name = "ACM server: cirno"
	}
}

module "deployment" {
	source = "git::https://github.com/Gabriella439/terraform-nixos-ng.git//nixos?ref=af1a0af57287851f957be2b524fcdc008a21d9ae"
	flake = ".#cirno"
	host = "root@${local.chosen_address}"
	ssh_options = "-i ${var.ssh_private_key_file} -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
}
