terraform {
	required_version = ">= 1.2.0"

	backend "local" {
		path = "./secrets/terraform.tfstate"
	}

	required_providers {
		aws = {
			source	= "hashicorp/aws"
			version = "~> 4.16"
		}
	}
}

locals {
	ssh = {
		private_key = "./secrets/ssh/id_ed25519"
		public_key  = "./secrets/ssh/id_ed25519.pub"
	}
}

module "nixos_image" {
	source	= "git::https://github.com/swdunlop/terraform-nixos.git//aws_image_nixos?ref=79219181ded4b7430d3323ec377a7cee11b2ade0"
	release = "21.05"
}

resource "aws_key_pair" "secrets_ssh" {
	key_name = "acm-secrets-ssh"
	public_key = file(local.ssh.public_key)
}

provider "aws" {
	profile = "acm"
}

resource "aws_security_group" "ssh" {
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = [ "0.0.0.0/0" ]
	}
}

resource "aws_security_group" "egress" {
	egress {
		from_port = 0
		to_port	= 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_instance" "cirno" {
	ami = module.nixos_image.ami
	instance_type = "t2.micro"
	key_name = aws_key_pair.secrets_ssh.key_name
	security_groups = [
		aws_security_group.ssh.name,
		aws_security_group.egress.name
	]
	tags = {
		Name = "ACM server: cirno"
	}
}

module "nixos_cirno" {
	source = "git::https://github.com/diamondburned/terraform-nixos.git//deploy_nixos?ref=ab1f99dbde70b6c9b57173b1f4bd1ffbc99506c5"
	nixos_config = "${path.module}/servers/cirno/configuration.nix"
	target_host = aws_instance.cirno.public_ip
	ssh_private_key_file = local.ssh.private_key
	ssh_agent = false
}
