{ ... }:
let
  lanAddress = "192.168.11.62";
in
{
  containers.pihole-unbound = {
    autoStart = true;
    privateNetwork = true;
    macvlans = [ "eno1" ];

    config =
      { ... }:
      {
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
              hosts = [
                "${lanAddress} dns.home.arpa"
                "192.168.11.63 nas.home.arpa"
                "192.168.11.64 search.home.arpa"
              ];
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
}
