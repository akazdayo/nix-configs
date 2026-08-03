{ config, lib, ... }:
let
  containerData = config.local.containers.network;
  nextcloudData = config.local.containers.nextcloud;
in
{
  options.local.containers.nextcloud = lib.mkOption { type = lib.types.attrs; };

  config = {
    containers.nextcloud = {
      autoStart = true;
      privateNetwork = true;
      macvlans = [ containerData.hostInterface ];
      bindMounts = {
        # Legacy host-local secret path. Keep /etc/nextcloud-adminpass on the
        # host and preserve this non-sops path during the refactor.
        "/run/secrets/nextcloud-adminpass" = {
          hostPath = nextcloudData.adminPassHostPath;
          isReadOnly = true;
        };
      };

      config =
        { ... }:
        {
          networking.interfaces.${containerData.containerInterface} = {
            useDHCP = false;
            ipv4.addresses = [
              {
                address = nextcloudData.address;
                prefixLength = nextcloudData.prefixLength;
              }
            ];
          };
          networking.defaultGateway = containerData.defaultGateway;
          networking.nameservers = containerData.nameservers;

          services.nextcloud = {
            enable = true;
            hostName = nextcloudData.address;
            https = false;
            config = {
              adminuser = "admin";
              adminpassFile = "/run/secrets/nextcloud-adminpass";
              dbtype = "pgsql";
            };
            settings.trusted_domains = nextcloudData.trustedDomains;
            database.createLocally = true;
          };

          services.nginx.enable = true;

          networking.firewall = {
            allowedTCPPorts = [
              80
              443
            ];
          };

          system.stateVersion = "25.11";
        };
    };
  };
}
