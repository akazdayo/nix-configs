{ config, lib, ... }:
{
  options.local.containers.network = {
    hostInterface = lib.mkOption { type = lib.types.str; };
    containerInterface = lib.mkOption { type = lib.types.str; };
    defaultGateway = lib.mkOption { type = lib.types.str; };
    nameservers = lib.mkOption { type = lib.types.listOf lib.types.str; };
  };

  config.networking.networkmanager.unmanaged = [ config.local.containers.network.hostInterface ];
}
