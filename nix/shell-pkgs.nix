let pkgs = import ./nixpkgs.nix; in with pkgs; [
	terraform
	awscli2
	nix_2_3
	nix-update
	niv
	git
	git-crypt
	yamllint
	gomod2nix
	expect
]
