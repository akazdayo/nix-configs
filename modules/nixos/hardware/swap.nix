{ config, lib, ... }:
let
  cfg = config.local.hardware.swap;
in
{
  options.local.hardware.swap = {
    device = lib.mkOption { type = lib.types.str; };
    size = lib.mkOption {
      type = lib.types.int;
      default = 2 * 1024;
    };
  };

  config.swapDevices = [ cfg ];
}
