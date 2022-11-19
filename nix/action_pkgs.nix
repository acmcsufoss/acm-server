let commit = "ac20a8605b0f79be2d65d995cd347251cd5b984b"; # nixos-22.05
	pkgsSrc = builtins.fetchTarball {
		url = "https://github.com/NixOS/nixpkgs/archive/${commit}.tar.gz";
		sha256 = "184asc3j4vg0qys10yqlla5h05wfb3jm062lwzsrlnjw2yq7nll3";
	};
	pkgs = import pkgsSrc {};

in import ./dev_pkgs.nix {
	inherit pkgs;
}
