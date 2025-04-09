.PHONY: hash
vendorHash: tidy
	echo > vendorHash.txt
	nix build --no-link '.#caddy.goModules' \
		|& sed -n 's/.*\(sha256-.\{44\}\).*/\1/p' \
		|  grep -vF "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" \
		>  vendorHash.txt

.PHONY: tidy
tidy: go.mod go.sum
	GOTOOLCHAIN=local go mod tidy
