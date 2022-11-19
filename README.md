# acm-aws

acm-aws contains the Terraform deployment files for acmCSUF. It uses Terraform
and Nix to orchestrate cloud servers.

## Setting Up

You need Terraform, Nix and git-crypt to develop and deploy. It's most
recommended if you have `nix-shell`.

For instructions on how to install Nix, see [Nix >
Download](https://nixos.org/download.html). It should just be one command.

To set up git-crypt, run:

```sh
git-crypt init
```

Afterwards, initialize the local Terraform workspace:

```sh
terraform init
```

## Deploying

Run:

```sh
terraform apply
```

## Quick Tasks

The sections underneath describe small tasks that may be useful in certain
scenarios.

### SSH

```sh
# Example: ./scripts/ssh <server name>

./scripts/ssh cirno
```

### Obtaining an IP Address

```sh
# Example: ./scripts/ip <server name>

ip=$(./scripts/ip cirno)
curl -v ${ip}:80
```

### Updating a Dependency

```sh
# Example: ./scripts/update-pkg <package name>

./scripts/update-pkg acmregister
```
