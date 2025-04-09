{ pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/amazon-image.nix")
    ./services.nix
  ];

  nixpkgs.system = "x86_64-linux";

  networking.hostName = "cirno";

  services.tailscale.enable = true;

  # Use Terraform's AWS rules for this.
  networking.firewall.enable = false;

  # This isn't needed, since we're just deploying stock AMIs and bootstrapping
  # it with Terraform outside of AWS configurations.
  virtualisation.amazon-init.enable = false;

  environment.systemPackages = with pkgs; [
    ncdu
  ];
}
