{ config, lib, ... }:
let
  cfg = config.local.networking.staticIPv4;
in
{
  options.local.networking.staticIPv4 = {
    interface = lib.mkOption { type = lib.types.str; };
    address = lib.mkOption { type = lib.types.str; };
    prefixLength = lib.mkOption { type = lib.types.int; };
    defaultGateway = lib.mkOption { type = lib.types.str; };
  };

  config = {
    networking.interfaces.${cfg.interface} = {
      useDHCP = false;
      ipv4.addresses = [
        {
          inherit (cfg) address prefixLength;
        }
      ];
    };
    networking.defaultGateway = cfg.defaultGateway;
  };
}
