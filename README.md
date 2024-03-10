# acm-aws

![Deployment status badge](https://github.com/acmcsufoss/acm-aws/actions/workflows/deploy.yml/badge.svg?branch=main)

acm-aws contains the Terraform deployment files for ACM at CSUF. It uses
Terraform and Nix to orchestrate cloud servers.

## What is?

### Terraform

Terraform is a tool that allows us to declare infrastructure as code (IaC). In
other words, it allows us to declare what we want cloud providers (e.g. AWS) to
do for us in code without having to touch buttons.

The entire process of orchestrating cloud servers is automated using this tool,
and any changes are done on these version-controlled text files, not any UI.

### Nix

Nix (used here) is a declarative package manager. Unlike any traditional package
manager, Nix is used as a programming language capable of reproducing package
builds in a sane manner with everything written in files.

Similarly to Terraform, Nix's input files will help us manage the servers in a
more automatic fashion by allowing us to declare what we want on the servers and
have everything else handled automatically.

## Project Structure

acm-aws has several root directories:

- nix/ contains internal Nix files, such as the sources for some of our
  packages.
- packages/ contains our own Nix package files.
- scripts/ contains utility scripts. See the "Quick Tasks" section.
- secrets/ contains deployment secrets such as tokens. This should never be
  pushed decrypted.
- servers/ contains all the files that define servers.
	- servers/base.nix is the base Nix server declaration.
	- servers/cirno/* contains the files for just the `cirno` server.
- main.tf declares the root Terraform module. Applying this file will deploy all
  of our servers.

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

> [!IMPORTANT]
> The only way to deploy to our servers is via Terraform, either done locally
> or through GitHub Actions. **Do not** manually change anything on the servers
> without going through Terraform.

### Deploy locally

To deploy locally, ensure you have Nix installed and have loaded the Nix shell.
Then, run:

```sh
terraform apply
```

### Deploy using GitHub Actions

To deploy using GitHub Actions, push to the `main` branch. This will trigger the
GitHub Actions workflow, which will deploy the servers.

## Documentation

For more detailed documentation, see the [Documentation folder](./docs/).
