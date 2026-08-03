{ config, lib, ... }:
let
  cfg = config.local.networking.macvlanShim;
in
{
  options.local.networking.macvlanShim = {
    name = lib.mkOption { type = lib.types.str; };
    parentInterface = lib.mkOption { type = lib.types.str; };
    address = lib.mkOption { type = lib.types.str; };
    routeAddresses = lib.mkOption { type = lib.types.listOf lib.types.str; };
  };

  config = {
    networking.macvlans.${cfg.name} = {
      interface = cfg.parentInterface;
      mode = "bridge";
    };
    networking.interfaces.${cfg.name} = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = cfg.address;
          prefixLength = 32;
        }
      ];
      ipv4.routes = map (address: {
        inherit address;
        prefixLength = 32;
        options = {
          scope = "link";
          src = cfg.address;
        };
      }) cfg.routeAddresses;
    };
    networking.networkmanager.unmanaged = [ cfg.name ];
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.arp_ignore" = 1;
      "net.ipv4.conf.all.arp_announce" = 2;
      "net.ipv4.conf.default.arp_ignore" = 1;
      "net.ipv4.conf.default.arp_announce" = 2;
      "net.ipv4.conf.${cfg.parentInterface}.arp_ignore" = 1;
      "net.ipv4.conf.${cfg.parentInterface}.arp_announce" = 2;
    };
  };
}
