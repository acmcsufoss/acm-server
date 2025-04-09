{
  self,
  pkgs,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/minimal.nix")

    self.nixosModules.static
    self.nixosModules.healthcheck
    self.nixosModules.services-managed
  ];

  services.journald = {
    enableHttpGateway = false;
    extraConfig = ''
      Compress=true
      SystemMaxUse=50M
      SystemMaxFileSize=1M
      RuntimeMaxUse=1M
      MaxRetentionSec=6month
    '';
  };

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  environment.systemPackages = with pkgs; [
    htop
  ];

  users.users.root.openssh.authorizedKeys.keyFiles = [
    (self.lib.secret "ssh/id_ed25519.pub")
  ];

  # Deploy ./static to all servers.
  deployment.staticPaths = [ ../static ];
}
