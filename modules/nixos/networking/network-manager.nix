{ config, lib, ... }:
let
  cfg = config.local.networking.networkManager;
in
{
  options.local.networking.networkManager = {
    nameservers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    unmanagedInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = {
    networking.nameservers = cfg.nameservers;
    networking.networkmanager = {
      enable = true;
      unmanaged = cfg.unmanagedInterfaces;
    };
    services.nscd.enableNsncd = true;
  };
}
