# Packaging on Nix

Nix contains various guides on how to package for Nixpkgs. This guide will
mainly focus on packaging for this server.

The process of packaging mainly contains the following steps:

1. Add the repository into the sources list.
2. Make a Nix package.
3. Make a systemd service.
4. Optionally, package a Nix service option that uses the systemd service or use
   it directly in the configuration.

## Adding a Source

Before you start packaging things for Nix, you need to know where to download
the source code of your project. In this repository, we keep track of all known
sources in `nix/sources.json`.

To add a GitHub repository into the package source list, use the command

```sh
niv add github-username/github-repo
```

To use the source in Nix, do

```nix
let sources = import <acm-aws/nix/sources.nix>;

in {
  src = sources.github-repo;
}
```

Adding source code from sources other than GitHub is a bit more complicated.
Refer to `niv add --help` for more information.

## Making a Nix package

Like many other Linux distributions, when you "make a package," you're writing
files that let the system's package manager know how to install the program into
the system for the user to use.

Since Nix is a source-based package manager, packaging in Nix involves telling
Nix what build tools we need (and often how it should build them). However,
because Nix is also a functional programming language, we don't often tell it
what commands to run.

This section will go through packaging some of the most common programming
languages. Hopefully, you'll get the gist of it.

If you cannot find the programming language that you want to package for, refer
to the [Nixpkgs manual, ch. 17 (Languages and Frameworks)](https://nixos.org/manual/nixpkgs/stable/#chap-language-support).

> [!NOTE]
> Nix package files usually go in `./packages/` as a directory (e.g.
> `./packages/program/default.nix`).

Once the package file is written, they need to be added into
`packages/default.nix` like so:

```nix
{ pkgs ? import <acm-aws/nix/nixpkgs.nix> }:

rec {
  # Other stuff...
  program = pkgs.callPackage ./program { };
  # Other stuff...
}
```

### Python

The recommended way to package Python projects is to convert that project to
use Poetry for dependency management. This is because Poetry can generate a
`pyproject.toml` file that Nix can use to build the package.

> [!IMPORTANT]
> Make sure that you're able to run the project using `poetry run python -m
> <MODULE_PATH>` before you start packaging it.

Once that's done, simply use `buildPoetryPackage`:

```nix
{ buildPoetryPackage }:

let
  sources = import <acm-aws/nix/sources.nix>;
in

buildPoetryPackage {
  pname = "project-name";
  module = "path.to.python.module";
  src = sources.project-name;
}
```

### JavaScript

TODO. Use `buildNpmPackage`: https://github.com/serokell/nix-npm-buildpackage

### Deno

```nix
{ buildDenoPackage }:

buildDenoPackage rec {
  pname = "pomo";
  src = (import <acm-aws/nix/sources.nix>).pomo;
  entrypoint = "server/main.ts";
  # TODO: fill this in once you have it.
  # See buildGoModule's vendorSha256 for more info.
  outputHash = "";
}
```

### Go

```nix
# Define the inputs of our package. We're building using Go 1.19, so that's what
# we want. We can also use buildGoModule, which will use whichever one that's
# new enough.
{ buildGo119Module }:

let
  sources = import <acm-aws/nix/sources.nix>;
in

buildGo119Module {
  pname = "acmregister";
  version = "main";
  src = sources.acmregister;

  # Use an empty vendorHash hash. This forces Nix to fetch a new set of Go #
  # dependencies for our package. The hash can later be updated by running
  # ./scripts/pkg update <name>.
  vendorHash = "";

  # This is optional, but we can specify what Go package to build within the
  # module to avoid having to build all packages. This is useful if the module
  # contains multiple unnecessary package mains.
  # subPackages = [ "." ];
}
```

> **Note**: if the source repository uses Go workspace, then packaging it
> becomes a bit more tedious. Adding `GOWORK = "off";` should fix it.

## Making a systemd service

systemd is the first process to run on Linux. One of its job is to ensure that
processes (called services) stay alive for as long as it needs to.

For example, if we want to run a Discord bot, we'd want it to stay up ideally
forever. By making the bot process a systemd service, we're entrusting that task
to the most reliable process on the server.

> **Note**: systemd service is not magic. It does not protect the process
> against data loss, power surge, etc. All it does is keep things alive for as
> long as it can manage to.

In most cases, adding a new systemd service is as simple as adding 2 lines of
code into the `services.nix` file under `services.managed.services`. This
module will automatically generate the systemd service file for us.

For example:

```nix
{
  services.managed.services = with lib; {
    hellobot = {
      # Set the command to run when our service starts. This should
      # usually be the binary name and whatever arguments that it needs.
      # Here, we're using /var/lib/hellobot, which is automatically
      # created by systemd.
      command = [ (getExe pkgs.hellobot) "--database-path" "/var/lib/hellobot" ];
      # Optionally clarify the environment variables that we want to pass
      # into our service. It is recommended that this be a Nix file inside a
      # folder named `secrets' for them to be hidden from public.
      environment = import <acm-aws/secrets/acm-nixie-env.nix>;
    };
  };
}
```

You can have a look at cs306's `services.nix` file to see how it looks
like with other actual services.

## Making a Nix service option (recommended)

If you choose to not be lazy, you can choose to write a nice Nix service option
that wraps around the systemd service.

A Nix service option often looks something like this:

```nix
{
  services.caddy = {
    enable = true;
    configFile = <acm-aws/secrets/Caddyfile>;
    environment = import <acm-aws/secrets/caddy-env.nix>;
  };
}
```

When doing this approach, we will want to make a directory for both the package
and the Nix service code:

- `packages/`
	- `hellobot/`
		- `default.nix`
			- This file will contain the package code. For example,
			  if we're making a Go package, then that file will contain
			  `buildGoModule` code.
		- `service.nix`
			- This file will contain our Nix service code that we'll be writing.
			  It will define all the options that we can use in
			  `configuration.nix`.

As an example, let's make a Nix service option for our `hellobot` service that
lets the user write something like this:

```nix
{ config, lib, pkgs, ... }:

{
  services.hellobot = {
    enable = true;
    httpAddress = "localhost:40002";
    environment = import <acm-aws/secrets/acm-nixie-env.nix>;
  };
}
```

### Writing `service.nix`

When writing a Nix service option, we will want to declare the options that we
want to expose to the user. This is done by setting a new attribute set inside
`options`.

> **Note**: the `options` attribute is a special attribute that is used to
> declare options, while the `config` attribute is used to read and write
> configuration values.

> **Note**: [I](https://github.com/diamondburned) strongly advise to use GitHub
> Copilot to write the options below. I don't really remember all the functions
> that I should be using, so I just use Copilot to write most of it.

> **Note**: we'll be using the term "attribute" and "attribute set" a lot. An
> "attribute set" is like a JSON object, while an "attribute" is like a JSON
> field within an object.

```nix
{ config, lib, pkgs, ... }:

# Put everything from lib into the global scope. Functions like lib.mkEnableOption
# can then be used without having to prefix them with lib. This is similar to
# C++'s using namespace std.
with lib;

# We declare a new variable `cfg' that contains all of the options that the user
# has set for this service.
let cfg = config.services.hellobot;

in {
  # Define the skeleton of the options that we want to expose to the user.
  options.services.hellobot = {
    # The `enable' option is a special option that is used to enable or
    # disable the service. It is a boolean option that defaults to false.
    enable = mkEnableOption "Enable the Hello world bot";

    # Define our httpAddress option. This is a string option that defaults
    # to "localhost:40002".
    httpAddress = mkOption {
      type = types.str;
      default = "localhost:40002";
      description = "The address that the bot should listen on";
    };

    # Define our environment option. This is an attribute set of string
    # values.
    environment = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Environment variables for the bot";
    };

    # Define the package that this service option is for. We'll just
    # directly import our package file to be the default one.
    package = mkOption {
      default = pkgs.callPackage ./default.nix {};
      type = types.package;
      description = "Caddy package to use.";
    };
  };

  # Define what will happen to the system configuration when this service
  # option is enabled.
  config = mkIf cfg.enable {
    # We install this package globally if the service is enabled. This lets
    # the user run `hellobot' from the command line.
    environment.systemPackages = [ cfg.package ];

    # We put our systemd service that we just wrote into the system
    # configuration here.
    systemd.services.hellobot = {
      enable = true;
      description = "Hello world bot";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      # Pay attention here. We use the environment option that the user
      # set while using services.hellobot.environment.
      environment = cfg.environment;
      serviceConfig = {
        Type = "simple";
        RuntimeDirectory = "hellobot";
        # This is also different: we use the options that the user set
        # instead of hard-coding them. The exception is database-path,
        # which we let systemd handle.
        ExecStart = ''
          ${cfg.package}/bin/hellobot \
            --database-path /var/lib/hellobot \
            --http-address ${cfg.httpAddress}
        '';
        User = "nobody";
        Group = "nobody";
      };
    };
  };
}
```

For more resources:

- NixOS Wiki's [Declaration/Types][nixos-wiki-decl-types]
  section goes through a list of types that can be used in the options.
- Nixpkgs'
  [lib/options.nix][nixpkgs-lib-options] file also contains a list of functions
  that construct options, such as `mkOption`.

[nixos-wiki-decl-types]: https://nixos.wiki/wiki/Declaration#Types
[nixpkgs-lib-options]: https://github.com/NixOS/nixpkgs/blob/master/lib/options.nix

### Registering `service.nix`

`service.nix` files need to be imported into the system configuration. We have a
single file that keeps track of all such imports.

To add a new `service.nix` file, go to `./packages/imports.nix` and add it to
the `imports` list:

```nix
{ config, pkgs, lib, ... }:

let ...;

in {
  imports = [
    # ...
    ./hellobot/service.nix
    # ...
  ];
}
```

### Using the new service

Once we're done with the above steps, we can drop our new option settings into
our `configuration.nix` file:

```nix
{ config, lib, pkgs, ... }:

{
  # Other stuff...

  services.hellobot = {
    enable = true;
    httpAddress = "localhost:40002";
    environment = import <acm-aws/secrets/acm-nixie-env.nix>;
  };

  # Other stuff...
}
```

> **Note**: NixOS defines many options similar to the one that we just made. To
> search for what's available, go to [search.nixos.org/options](https://search.nixos.org/options).
> There are over 10,000 options available!
>
> Here are some options that you might be interested in:
>
> - `systemd.services`
> - `services.postgresql`
> - `services.minecraft-server`
> - `networking.firewall`
> - `environment.systemPackages`
>

## Optional: Package Makefiles

Packages that need to run additional commands before it can be built in Nix can
create a Makefile to do so. A few common use cases are:

- Regenerating a hash/lock file for a package. For example, `caddy` needs to
  regenerate its `gomod2nix.toml` file based on the `go.mod` file.
- There might be more...

To create a Makefile, create a `Makefile` file in the package directory. For
example, `./packages/caddy/Makefile`:

```makefile
# The first target is always run by `scripts/pkg make`.
gomod2nix.toml: go.mod go.sum
    go mod download
    gomod2nix
```

> **Note**: All package Makefiles are run during the deployment process within
> the GitHub Actions workflow. Deploying locally does not run the Makefiles.
