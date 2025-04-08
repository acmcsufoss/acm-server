{
  system,
  inputs,
  nivInputs,
}:

let
  fullyhacks-qrms = (import inputs.flake-compat { src = nivInputs.fullyhacks-qrms; }).defaultNix;
in
fullyhacks-qrms.packages.${system}.default
