{ pkgs, fetchFromGitHub, buildGo121Module, lib }:
 
buildGo121Module rec {
  pname = "discord_conversation_summary_bot";
  version = builtins.substring 0 7 src.rev;
  src = (import <acm-aws/nix/sources.nix>).discord_conversation_summary_bot;
  vendorHash = "sha256-c+VaWf9AQW/gtgAdaw0UtYm+k+zAklfDcz20zFMmalI=";
}
