{ config, lib, ... }:
let
  cfg = config.local.hardware.fileSystems;
  fileSystemType = lib.types.submodule {
    options = {
      mountPoint = lib.mkOption { type = lib.types.str; };
      device = lib.mkOption { type = lib.types.str; };
      fsType = lib.mkOption { type = lib.types.str; };
      options = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      autoMountUuid = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
  };
  autoMounts = lib.filterAttrs (_: value: value.autoMountUuid != null) cfg;
in
{
  options.local.hardware.fileSystems = lib.mkOption {
    type = lib.types.attrsOf fileSystemType;
  };

  config = {
    fileSystems = lib.mapAttrs' (
      _: value:
      lib.nameValuePair value.mountPoint {
        inherit (value) device fsType;
      }
      // lib.optionalAttrs (value.options != [ ]) { inherit (value) options; }
    ) cfg;

    services.udev.extraRules = lib.concatLines (
      lib.mapAttrsToList (
        _: value:
        ''ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_UUID}=="${value.autoMountUuid}", TAG+="systemd", ENV{SYSTEMD_WANTS}="${
          lib.removePrefix "/" (lib.replaceStrings [ "/" ] [ "-" ] value.mountPoint)
        }.mount"''
      ) autoMounts
    );
  };
}
