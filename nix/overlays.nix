{ nixpkgs, ... }@inputs:

nixpkgs.lib.composeManyExtensions [
  (inputs.gomod2nix.overlays.default)
  (inputs.nix-npm-buildpackage.overlays.default)
  (self: super: {
    poetry2nix = import inputs.poetry2nix { pkgs = super; };
  })
  (self: super: {
    buildDenoPackage = self.callPackage ./packaging/deno.nix { };
    buildJavaPackage = self.callPackage ./packaging/java.nix { };
    buildGradlePackage = self.callPackage ./packaging/gradle.nix { };
    buildPoetryPackage = self.callPackage ./packaging/poetry.nix { };
  })
  (self: super: {
    nix-update = super.callPackage ./nix-update.nix { };
  })
]
