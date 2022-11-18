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
	source = "git::https://github.com/diamondburned/terraform-nixos.git//deploy_nixos?ref=ab1f99dbde70b6c9b57173b1f4bd1ffbc99506c5"
	nixos_config = "${path.module}/configuration.nix"
	target_host = aws_instance.cirno.public_ip
	ssh_private_key_file = var.ssh_private_key_file
	ssh_agent = false
	/* build_on_target = true */
}
