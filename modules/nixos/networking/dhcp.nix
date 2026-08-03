{ config, lib, ... }:
{
  options.local.networking.dhcp.interface = lib.mkOption {
    type = lib.types.str;
  };

  config = {
    networking.networkmanager.enable = true;
    networking.interfaces.${config.local.networking.dhcp.interface}.useDHCP = true;

    # The base OpenStack image already runs its metadata bootstrap service.
    services.cloud-init.enable = false;
  };
}
