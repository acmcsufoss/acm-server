{
  lib,
  buildGo123Module,
}:

with lib;

buildGo123Module {
  pname = "caddy";
  version = "v2.6.2";
  src = ./.;

  vendorHash = builtins.readFile ./vendorHash.txt;

  subPackages = [ "." ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://caddyserver.com";
    description = "Fast, cross-platform HTTP/2 web server with automatic HTTPS";
    license = licenses.asl20;
  };
}
