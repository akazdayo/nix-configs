{ hostMeta, pkgs, ... }:
let
  containerData = hostMeta.hostData.containers;
  atticData = containerData.attic;
in
{
  # Attic setup notes:
  # - Generate the RS256 secret:
  #     openssl genrsa -traditional 4096 | base64 -w0
  # - Encrypt it with sops:
  #     sops secrets/server/attic.yaml
  #   with content:
  #     ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64="<output>"
  # - Generate a CI token:
  #     atticd-atticadm make-token --sub "github-actions" --validity "10y" --pull "*" --push "*" --create-cache "*" --configure-cache "*" --configure-cache-retention "*"
  # - Create a cache:
  #     attic cache create <name>
  # - Client usage:
  #     attic login server https://attic.odango.app <token>
  #     attic use server:<cache>
  systemd.tmpfiles.rules = [
    "d ${atticData.hostDataRoot} 0755 root root -"
    "d ${atticData.hostDataRoot}/data 0755 root root -"
  ];

  containers.attic = {
    autoStart = true;
    privateNetwork = true;
    macvlans = [ containerData.hostInterface ];
    bindMounts = {
      "/var/lib/atticd" = {
        hostPath = "${atticData.hostDataRoot}/data";
        isReadOnly = false;
      };
      "/run/secrets/atticd-env" = {
        hostPath = atticData.environmentHostPath;
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

        services.atticd = {
          enable = true;
          environmentFile = "/run/secrets/atticd-env";
          settings = {
            listen = "0.0.0.0:8080";
            api-endpoint = "https://${atticData.apiDomain}/";
            allowed-hosts = [ atticData.apiDomain ];
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
}
