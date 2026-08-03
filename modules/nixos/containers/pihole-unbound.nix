{ config, lib, ... }:
let
  containerData = config.local.containers.network;
  piholeData = config.local.containers.piholeUnbound;
  lanAddress = piholeData.address;
in
{
  options.local.containers.piholeUnbound = lib.mkOption { type = lib.types.attrs; };

  config = {
    containers.pihole-unbound = {
      autoStart = true;
      privateNetwork = true;
      macvlans = [ containerData.hostInterface ];

      config =
        { ... }:
        {
          networking.interfaces.${containerData.containerInterface} = {
            useDHCP = false;
            ipv4.addresses = [
              {
                address = lanAddress;
                prefixLength = piholeData.prefixLength;
              }
            ];
          };
          networking.defaultGateway = containerData.defaultGateway;
          networking.nameservers = containerData.nameservers;

          services.unbound = {
            enable = true;
            resolveLocalQueries = false;
            settings.server = {
              interface = [ "127.0.0.1" ];
              port = 5335;
              access-control = [ "127.0.0.0/8 allow" ];
              do-ip6 = false;
              harden-glue = true;
              hide-identity = true;
              hide-version = true;
              prefetch = true;
            };
          };

          services.pihole-ftl = {
            enable = true;
            lists = [
              {
                url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
                type = "block";
                enabled = true;
                description = "StevenBlack Unified Hosts";
              }
            ];
            settings = {
              dns = {
                upstreams = [ "127.0.0.1#5335" ];
                hosts = piholeData.hosts;
                dnssec = true;
                bogusPriv = true;
                domainNeeded = true;
              };
            };
          };

          services.pihole-web = {
            enable = true;
            ports = [ "80o" ];
          };

          networking.firewall = {
            allowedTCPPorts = [
              53
              80
            ];
            allowedUDPPorts = [ 53 ];
          };

          system.stateVersion = "25.11";
        };
    };
  };
}
