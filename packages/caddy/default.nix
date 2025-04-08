{
  lib,
  buildGoApplication,
  go_1_21,
}:

with lib;

buildGoApplication {
  pname = "caddy";
  version = "v2.6.2";
  src = ./.;

  go = go_1_21;
  modules = ./gomod2nix.toml;
  subPackages = [ "." ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://caddyserver.com";
    description = "Fast, cross-platform HTTP/2 web server with automatic HTTPS";
    license = licenses.asl20;
  };
}
