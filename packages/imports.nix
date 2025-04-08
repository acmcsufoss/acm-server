{ self, ... }:

{
  imports = [
    ./caddy/caddy.nix
    ./sysmet/sysmet.nix
    ./sshwifty/service.nix
    ./dischord/service.nix
    ./christmasd/service.nix
  ];

  nixpkgs.overlays = [
    self.overlays.base
    self.overlays.packages
  ];
}
