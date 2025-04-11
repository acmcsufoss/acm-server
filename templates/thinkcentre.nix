# Usage:
#
#   $ nix build .#nixosConfigurations.template-thinkcentre.config.system.build.diskoImagesScript
#   $ sudo ./result --build-memory 2048
#
# Reference:
#
#   - https://github.com/nix-community/disko/blob/master/lib/make-disk-image.nix
#
{ inputs, ... }:

let
  # Change me if needed.
  diskPath = "/dev/sda";
in

{
  imports = [
    inputs.disko.nixosModules.disko

    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
  ];

  nixpkgs.system = "x86_64-linux";

  system.stateVersion = "24.11";

  networking = {
    hostName = "thinkcentre-newly-provisioned";
    networkmanager.enable = true;
  };

  services.openssh = {
    # Allow SSH access to freshly provisioned machines.
    enable = true;
    # Completely disable password authentication.
    # To SSH, use the shared SSH key in secrets.
    settings.PasswordAuthentication = false;
  };

  boot = {
    kernelParams = [
      "console=tty0"
    ];
    kernelModules = [
      "kvm-intel"
    ];
    supportedFilesystems = [
      "btrfs"
    ];
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "uas"
      ];
      kernelModules = [
        "dm-snapshot"
      ];
      systemd = {
        enable = true;
        # Enable repart, which allows the system to grow the root partition
        # before it finishes booting. This lets us flash the image onto a real
        # disk and have it automatically resize!
        repart.enable = true;
      };
    };
    loader.grub = {
      device = diskPath;
      efiSupport = false;
      timeoutStyle = "hidden";
    };
  };

  disko.devices.disk = {
    main = {
      type = "disk";
      device = diskPath;
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02"; # for GRUB MBR (hybrid EFI/BIOS boot)
          };
          # boot = {
          #   size = "512M";
          #   type = "EF00"; # for EFI boot
          #   content = {
          #     type = "filesystem";
          #     format = "vfat";
          #     mountpoint = "/boot";
          #     mountOptions = [
          #       "defaults"
          #     ];
          #   };
          # };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/rootfs" = {
                  mountpoint = "/";
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/swap" = {
                  mountpoint = "/swap";
                  # Sane default but can be changed
                  # later per-system if needed.
                  swap.swapfile.size = "8G";
                };
              };
            };
          };
        };
      };
      # This is specifically for building disko images, which are used just for
      # provisioning a new drive directly. See:
      # https://github.com/nix-community/disko/blob/master/docs/disko-images.md
      imageName = "servertemplate-thinkcentre";
      imageSize = "25G";
    };
  };
}
