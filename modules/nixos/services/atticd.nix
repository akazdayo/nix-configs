{ config, hostMeta, ... }:
let
  atticdData = hostMeta.hostData.atticd or { };
  domain = atticdData.domain or (throw "hostData.atticd.domain must be set");
in
{
  services.atticd = {
    enable = true;
    environmentFile = config.sops.secrets.atticd-env.path;
    settings = {
      listen = atticdData.listen or "[::]:8080";
      allowed-hosts = [ domain ];
      api-endpoint = "https://${domain}/";
      compression.type = "zstd";
      garbage-collection = {
        interval = "12 hours";
        default-retention-period = "6 months";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];

  environment.systemPackages = [
    config.services.atticd.package
  ];
}
