{
  static = import ./static.nix;
  healthcheck = import ./healthcheck.nix;
  services-managed = import ./services-managed.nix;
}
