{ self, ... }:

{
  imports = [
    self.nixosModules.base
    self.nixosModules.template-thinkcentre
  ];

  networking.hostName = "cs306-thinkcentre-1";

  # Double-checked via SSH.
  disko.devices.disk.main.device = "/dev/sda";
}
