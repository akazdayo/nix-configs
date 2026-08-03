{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.local.boot.lanzaboote.pkiBundle = lib.mkOption {
    type = lib.types.str;
  };

  config = {
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = config.local.boot.lanzaboote.pkiBundle;
    };
    boot.supportedFilesystems = [
      "ntfs"
      "ext4"
      "btrfs"
      "xfs"
    ];
    environment.systemPackages = [ pkgs.sbctl ];
  };
}
