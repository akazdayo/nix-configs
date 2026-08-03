{
  config,
  lib,
  pkgs,
  ...
}:
let
  containerData = config.local.containers.network;
  atticData = config.local.containers.attic;
in
{
  options.local.containers.attic = lib.mkOption { type = lib.types.attrs; };

  config = {
    sops.secrets.atticd-env = {
      sopsFile = atticData.environmentSopsFile;
      owner = "root";
      mode = "0400";
    };

    systemd.tmpfiles.rules = [
      "d ${atticData.dataRoot} 0755 root root -"
      "d ${atticData.dataRoot}/data 0755 root root -"
    ];

    containers.attic = {
      autoStart = true;
      privateNetwork = true;
      macvlans = [ containerData.hostInterface ];
      bindMounts = {
        "/var/lib/atticd" = {
          hostPath = "${atticData.dataRoot}/data";
          isReadOnly = false;
        };
        "/run/secrets/atticd-env" = {
          hostPath = config.sops.secrets.atticd-env.path;
          isReadOnly = true;
        };
      };

      config =
        { ... }:
        {
          networking.hostName = atticData.hostName;
          networking.interfaces.${containerData.containerInterface} = {
            useDHCP = false;
            ipv4.addresses = [
              {
                address = atticData.address;
                prefixLength = atticData.prefixLength;
              }
            ];
          };
          networking.defaultGateway = containerData.defaultGateway;
          networking.nameservers = containerData.nameservers;
          networking.firewall.allowedTCPPorts = [ 8080 ];

          users.groups.atticd = { };
          users.users.atticd = {
            isSystemUser = true;
            group = "atticd";
          };

          systemd.services.atticd.serviceConfig = {
            DynamicUser = lib.mkForce false;
            User = "atticd";
            Group = "atticd";
          };

          systemd.tmpfiles.rules = [
            "d /var/lib/atticd 0750 atticd atticd -"
            "d /var/lib/atticd/storage 0750 atticd atticd -"
          ];

          services.atticd = {
            enable = true;
            environmentFile = "/run/secrets/atticd-env";
            settings = {
              listen = "0.0.0.0:8080";
              api-endpoint = "https://${atticData.apiDomain}/";
              allowed-hosts = [
                atticData.apiDomain
                "${atticData.apiDomain}:8080"
                "localhost"
                "localhost:8080"
                "127.0.0.1"
                "127.0.0.1:8080"
                atticData.address
                "${atticData.address}:8080"
              ];
              database.url = "sqlite:///var/lib/atticd/server.db?mode=rwc";
              storage = {
                type = "local";
                path = "/var/lib/atticd/storage";
              };
              compression.type = "zstd";
              chunking = {
                nar-size-threshold = 65536;
                min-size = 16384;
                avg-size = 65536;
                max-size = 262144;
              };
              garbage-collection = {
                interval = "12 hours";
                default-retention-period = "6 months";
              };
            };
          };

          environment.systemPackages = [
            pkgs.attic-client
          ];

          system.stateVersion = "25.11";
        };
    };
  };
}
