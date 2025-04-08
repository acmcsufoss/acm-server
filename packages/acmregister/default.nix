{
  system,
  inputs,
  nivInputs,
}:

# TODO: migrate to flake inputs
let
  acmregister = (import inputs.flake-compat { src = nivInputs.acmregister; }).defaultNix;
in
acmregister.packages.${system}.default
