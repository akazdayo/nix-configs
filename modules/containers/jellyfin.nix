{ ... }:
let
  hostDataRoot = "/var/lib/jellyfin-container";
  lanAddress = "192.168.11.65";
in
{
  systemd.tmpfiles.rules = [
    "d ${hostDataRoot} 0755 root root -"
    "d ${hostDataRoot}/config 0755 root root -"
    "d ${hostDataRoot}/cache 0755 root root -"
  ];

  containers.jellyfin = {
    autoStart = true;
    privateNetwork = true;
    macvlans = [ "eno1" ];
    bindMounts = {
      "/var/lib/jellyfin" = {
        hostPath = "${hostDataRoot}/config";
        isReadOnly = false;
      };

      "/var/cache/jellyfin" = {
        hostPath = "${hostDataRoot}/cache";
        isReadOnly = false;
      };

      "/media/kioxia" = {
        hostPath = "/mnt/kioxia";
        isReadOnly = true;
      };

      "/media/windows" = {
        hostPath = "/mnt/windows";
        isReadOnly = true;
      };

      "/media/vaio" = {
        hostPath = "/mnt/vaio";
        isReadOnly = true;
      };
    };

    config =
      { ... }:
      {
        networking.hostName = "jellyfin";

        networking.interfaces.mv-eno1 = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = lanAddress;
              prefixLength = 24;
            }
          ];
        };
        networking.defaultGateway = "192.168.11.1";
        networking.nameservers = [ "1.1.1.1" ];

        services.jellyfin = {
          enable = true;
          openFirewall = true;
        };

        networking.firewall.allowedTCPPorts = [
          8096
          8920
        ];

        system.stateVersion = "25.11";
      };
  };
}
