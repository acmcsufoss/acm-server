{
  buildGo119Module,
  fetchFromGitHub,
  lib,
}:

let
  sources = import <acm-aws/nix/sources.nix>;
  acmregister =
    (import sources.flake-compat {
      src = sources.acmregister;
    }).defaultNix;
in

acmregister
