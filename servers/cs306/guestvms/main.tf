provider "libvirt" {
  uri = "qemu+ssh://deploys@ams-kvm-remote-host/system"
}

variable "instances_file" {
  description = "The path to the instances file"
}

variable "image_url" {
  description = "The URL of the image to use"
}

variable "disk_size_gb" {
  description = "The size of the disk in GB"
  type = number
  default = 10
}

variable "memory_mb" {
  description = "The amount of memory in MB"
  type = number
  default = 256
}

variable "vcpu" {
  description = "The number of virtual CPUs"
  type = number
  default = 1
}

locals {
  instances = {
    for instance in jsondecode(file(var.instances_file)):
    format("guestvm-%s", instance.name) => {
      name = instance.name                # string
      ports = instance.ports              # map[string]int
      public_keys = instance.public_keys  # []string
    }
  }

  cloudinits = flatten([
    for instance in local.instances:
    instance.name => jsonencode({
      name = instance.name
      cloudinit = {
        ssh_pwauth = false
        disable_root = false
        users = [
          {
            name = "root"
            lock_passwd = false
            ssh_authorized_keys = instance.public_keys
          }
        ]
      }
    })
  ])

  network_config = jsonencode({
    version = 2
    ethernets = {
      ens3 = {
        dhcp4 = true
      }
    }
  })
}

resource "libvirt_pool" "guestvms_pool" {
  name = "guestvms_pool"
  type = "dir"
  path = "/var/lib/guestvms/images"
}

resource "libvirt_volume" "guestvms_volume" {
  for_each = {
    for instance in local.instances:
    format("%s.qcow2", instance.name) => instance
  }

  name = each.key
  pool = libvirt_pool.guestvms_pool.name
  size = var.disk_size_gb * 1024 * 1024 * 1024 # GB to bytes
  source = var.image_url
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "guestvms_cloudinit" {
  for_each = {
    for instance in local.instances:
    format("%s-cloudinit.iso", instance.name) => instance
  }

  name = each.key
  pool = libvirt_pool.guestvms_pool.name
  user_data = local.cloudinits[each.value.name]
  network_config = local.network_config
}

resource "libvirt_domain" "guestvms_domain" {
  for_each = {
    for instance in local.instances:
    format("%s", instance.name) => instance
  }

  name = each.key
  cloudinit = libvirt_cloudinit_disk.guestvms_cloudinit[each.value.name].id

  vcpu = var.vcpu
  memory = var.memory_mb

  network_interface {
    hostname = each.value.name
    network_name = "default"
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.guestvms_volume[each.value.name].id
  }

