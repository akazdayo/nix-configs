{ ... }:
{
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  boot.loader.efi.canTouchEfiVariables = false;

  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
  ];
}
