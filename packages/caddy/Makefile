.PHONY: hash
vendorHash: tidy
	vendorHash=$$(\
		nix build '.#caddy.goModules' \
			|& sed -n 's/.*\(sha256-.\{44\}\).*/\1/p' \
			|  grep -vF \
				-f "vendorHash.txt" \
				-e "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="\
	) \
		&& echo $${vendorHash} > vendorHash.txt \
		|| true # no updating needed

.PHONY: tidy
tidy: go.mod go.sum
	GOTOOLCHAIN=local go mod tidy
