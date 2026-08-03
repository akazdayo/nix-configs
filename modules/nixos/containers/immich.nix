{ config, lib, ... }:
let
  containerData = config.local.containers.network;
  immichData = config.local.containers.immich;
  dataRoot = immichData.dataRoot;
in
{
  options.local.containers.immich = lib.mkOption { type = lib.types.attrs; };

  config = {
    systemd.tmpfiles.rules = [
      "d ${dataRoot} 0755 root root -"
      "d ${dataRoot}/media 0755 root root -"
      "d ${dataRoot}/postgresql 0755 root root -"
      "d ${dataRoot}/redis 0755 root root -"
      "d ${dataRoot}/cache 0755 root root -"
    ];

    containers.immich = {
      autoStart = true;
      privateNetwork = true;
      macvlans = [ containerData.hostInterface ];
      bindMounts = {
        "/var/lib/immich" = {
          hostPath = "${dataRoot}/media";
          isReadOnly = false;
        };
        "/var/lib/postgresql" = {
          hostPath = "${dataRoot}/postgresql";
          isReadOnly = false;
        };
        "/var/lib/redis-immich" = {
          hostPath = "${dataRoot}/redis";
          isReadOnly = false;
        };
        "/var/cache/immich" = {
          hostPath = "${dataRoot}/cache";
          isReadOnly = false;
        };
      };

      config =
        { ... }:
        {
          networking.hostName = immichData.hostName;
          networking.interfaces.${containerData.containerInterface} = {
            useDHCP = false;
            ipv4.addresses = [
              {
                address = immichData.address;
                prefixLength = immichData.prefixLength;
              }
            ];
          };
          networking.defaultGateway = containerData.defaultGateway;
          networking.nameservers = containerData.nameservers;

          services.immich = {
            enable = true;
            host = "0.0.0.0";
            openFirewall = true;
            settings.server.externalDomain = immichData.externalDomain;
          };

          system.stateVersion = "25.11";
        };
    };
  };
}
