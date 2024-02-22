{ system ? builtins.currentSystem }:

let
	src   = import <acm-aws/nix/sources.nix>;
	flake = import src.fullyhacks-qrms;
in

flake.packages.${system}.default
