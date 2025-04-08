{
  pkgs,
  lib,
  python3,
  nix,
  nix-prefetch-git,
  nixpkgs-fmt,
  nixpkgs-review,
}:

let
  nivInputs = import ./sources.nix { inherit pkgs; };
in

python3.pkgs.buildPythonApplication rec {
  pname = "nix-update";
  version = builtins.substring 0 7 src.rev;
  pyproject = true;

  src = nivInputs.diamondburned_nix-update;

  nativeBuildInputs = [
    python3.pkgs.setuptools
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      nix
      nix-prefetch-git
      nixpkgs-fmt
      nixpkgs-review
    ])
  ];

  checkPhase = ''
    $out/bin/nix-update --help >/dev/null
  '';

  meta = with lib; {
    description = "Swiss-knife for updating nix packages";
    inherit (src.meta) homepage;
    license = licenses.mit;
    mainProgram = "nix-update";
    platforms = platforms.all;
  };
}
