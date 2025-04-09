{
  self,
  pkgs,
  lib,
  ...
}:

{
  imports = [
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

  documentation.enable = false;
  documentation.nixos.enable = false;

  programs.command-not-found.enable = false;

  xdg.autostart.enable = false;
  xdg.icons.enable = false;
  xdg.mime.enable = false;
  xdg.sounds.enable = false;

  # Exclude all default non-required packages for a lighter system.
  environment.defaultPackages = lib.mkForce [ ];

  environment.systemPackages = with pkgs; [
    htop
  ];

  users.users.root.openssh.authorizedKeys.keyFiles = [
    (self.lib.secret "ssh/id_ed25519.pub")
  ];

  # Deploy ./static to all servers.
  deployment.staticPaths = [ ../static ];
}
