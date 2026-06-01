{
  config,
  hostMeta,
  inputs,
  lib,
  ...
}:
let
  containerData = hostMeta.hostData.containers;
  rustfsData = containerData.rustfs;
in
{
  systemd.tmpfiles.rules = [
    "d ${rustfsData.hostDataRoot} 0755 root root -"
    "d ${rustfsData.hostDataRoot}/data 0755 root root -"
  ];

  containers.rustfs = {
    autoStart = true;
    privateNetwork = true;
    macvlans = [ containerData.hostInterface ];
    bindMounts = {
      "/var/lib/rustfs" = {
        hostPath = rustfsData.hostDataRoot;
        isReadOnly = false;
      };
      "/run/secrets/rustfs-env" = {
        hostPath = config.sops.templates."rustfs-env".path;
        isReadOnly = true;
      };
    };

    config =
      { ... }:
      {
        networking.hostName = rustfsData.hostName;
        networking.interfaces.${containerData.containerInterface} = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = rustfsData.address;
              prefixLength = rustfsData.prefixLength;
            }
          ];
        };
        networking.defaultGateway = containerData.defaultGateway;
        networking.nameservers = containerData.nameservers;

        networking.firewall.allowedTCPPorts = [ 9000 ];
        networking.firewall.extraCommands = ''
          iptables -A nixos-fw -p tcp --dport 9000 ! -s 192.168.11.66 -j nixos-fw-refuse
        '';

        users.groups.rustfs = { };
        users.users.rustfs = {
          isSystemUser = true;
          group = "rustfs";
        };

        systemd.tmpfiles.rules = [
          "d /var/lib/rustfs 0750 rustfs rustfs -"
          "d /var/lib/rustfs/data 0750 rustfs rustfs -"
        ];

        systemd.services.rustfs = {
          description = "RustFS Object Storage";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            ExecStart = "${
              lib.getExe inputs.rustfs.packages.${hostMeta.system}.default
            } --address :9000 /var/lib/rustfs/data";
            EnvironmentFile = "/run/secrets/rustfs-env";
            User = "rustfs";
            Group = "rustfs";
            Restart = "on-failure";
            RestartSec = "5s";
            LimitNOFILE = 65536;

            NoNewPrivileges = true;
            PrivateTmp = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            ReadWritePaths = [ "/var/lib/rustfs" ];
          };
        };

        system.stateVersion = "25.11";
      };
  };
}
