{ hostMeta, lib, ... }:
let
  shim = hostMeta.hostData.networking.macvlanShim or null;
in
{
  config = lib.mkIf (shim != null) {
    assertions = [
      {
        assertion = shim.prefixLength == 32;
        message = "networking.macvlanShim.prefixLength must be 32 to avoid routing the LAN subnet through the shim.";
      }
    ];

    networking.macvlans.${shim.name} = {
      interface = shim.parentInterface;
      mode = "bridge";
    };

    networking.interfaces.${shim.name} = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = shim.address;
          prefixLength = shim.prefixLength;
        }
      ];
      ipv4.routes = map (address: {
        inherit address;
        prefixLength = 32;
        options = {
          scope = "link";
          src = shim.address;
        };
      }) shim.routeAddresses;
    };

    networking.networkmanager.unmanaged = [ shim.name ];

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.arp_ignore" = 1;
      "net.ipv4.conf.all.arp_announce" = 2;
      "net.ipv4.conf.default.arp_ignore" = 1;
      "net.ipv4.conf.default.arp_announce" = 2;
      "net.ipv4.conf.${shim.parentInterface}.arp_ignore" = 1;
      "net.ipv4.conf.${shim.parentInterface}.arp_announce" = 2;
    };
  };
}
