{ pkgs, fetchFromGitHub, buildGo119Module, lib }:
 
buildGo119Module rec {
  pname = "discord-ical-srv";
  version = builtins.substring 0 7 src.rev;
 
  src = (import <acm-aws/nix/sources.nix>).discord-ical-srv;
  subPackages = [ "." ];
  vendorSha256 = "sha256-/xXU24sk5IRWfM/Bh9YYGB3mTDdhdATVlPzNxTKe2K0=";
}
