{ ... }:
{
  containers.searxng = {
    autoStart = true;
    privateNetwork = true;
    macvlans = [ "eno1" ];
    bindMounts = {
      # Secret key file. Create /etc/searx-env on the host with:
      #   SEARX_SECRET_KEY=$(openssl rand -hex 32)
      #   chmod 600 /etc/searx-env
      "/run/secrets/searx-env" = {
        hostPath = "/etc/searx-env";
        isReadOnly = true;
      };
    };

    config =
      { ... }:
      {
        networking.interfaces.mv-eno1 = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = "192.168.11.64";
              prefixLength = 24;
            }
          ];
        };
        networking.defaultGateway = "192.168.11.1";
        networking.nameservers = [ "1.1.1.1" ];

        services.searx = {
          enable = true;
          configureUwsgi = true;
          redisCreateLocally = true;
          environmentFile = "/run/secrets/searx-env";
          uwsgiConfig = {
            socket = "/run/searx/searx.sock";
            chmod-socket = "660";
          };
          settings = {
            server = {
              secret_key = "$SEARX_SECRET_KEY";
              limiter = true;
              public_instance = false;
            };
            general.instance_name = "SearXNG";
            ui.static_use_hash = true;
          };
        };

        # Allow caddy to reach the searx socket
        users.users.caddy.extraGroups = [ "searx" ];

        services.caddy = {
          enable = true;
          virtualHosts."http://search.home.arpa".extraConfig = ''
            reverse_proxy unix//run/searx/searx.sock
          '';
        };

        networking.firewall.allowedTCPPorts = [ 80 ];

        system.stateVersion = "25.11";
      };
  };
}
