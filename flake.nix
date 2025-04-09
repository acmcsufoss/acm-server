{
  description = "ACM at CSUF server deployments (github.com/acmcsufoss/acm-server)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    flake-util.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";

    gomod2nix.url = "github:nix-community/gomod2nix/v1.6.0";
    gomod2nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-npm-buildpackage.url = "github:serokell/nix-npm-buildpackage";
    nix-npm-buildpackage.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:

    {
      # Declare our servers here.
      # Our main.tf files will use this via flakes.
      nixosConfigurations = {
        # TODO: rename cirno to 'front-ec2' or something
        cirno = self.lib.nixosSystem ./servers/cirno/configuration.nix;
      };

      nixosModules = import ./modules/_all.nix;

      lib = rec {
        nixosSystem =
          configurationFile:
          nixpkgs.lib.nixosSystem {
            modules = [
              ./packages/imports.nix
              ./servers/base.nix
              configurationFile
            ];
            specialArgs = {
              inherit self inputs;
            };
          };

        sources =
          pkgs:
          import ./nix/sources.nix {
            inherit pkgs;
            inherit (pkgs) system;
          };
        nivInputs = sources; # same thing but clearer name

        sourceVersion =
          src: if (src ? version && src.version != "") then src.version else builtins.substring 0 7 src.rev;

        # Helper to get a path relative to the secrets directory.
        # TODO: Migrate to proper off-Nix Terraform secrets. See:
        #       - https://github.com/tweag/terraform-provider-secret
        #       - https://github.com/nix-community/terraform-nixos/blob/646cacb12439ca477c05315a7bfd49e9832bc4e3/examples/google/deploy_nixos.tf#L77-L81
        secret = path: ./secrets + ("/" + path);
      };

      overlays = {
        # This overlay contains the base packages that we need to build our
        # packages (the ones below).
        base = import ./nix/overlays.nix inputs;
        # The packages overlay is just for including all packages in our
        # repository.
        packages =
          self: super:
          import ./packages {
            inherit inputs;
            pkgs = super;
          };
      };
    }

    // (flake-utils.lib.eachDefaultSystem (system: {
      # Development shell declaration. This happens on `nix develop`.
      devShells.default =
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlays.base
            ];
            config.allowUnfreePredicate =
              pkg:
              builtins.elem (nixpkgs.lib.getName pkg) [
                "terraform" # :3
              ];
          };
        in
        pkgs.mkShell {
          packages = with pkgs; [
            cloud-init
            terraform
            awscli2
            nix-update
            jq
            niv
            git
            git-crypt
            openssl
            gomod2nix
            waypipe
            expect

            # editor tools.
            yamllint
            shellcheck
            nodePackages.bash-language-server
            # rnix-lsp
          ];

          shellHook = ''
            chmod 400 secrets/ssh/*
          '';
        };

      packages = import ./packages {
        inherit inputs;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.base ];
        };
      };
    }));
}
