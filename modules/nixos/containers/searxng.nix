{ config, lib, ... }:
let
  containerData = config.local.containers.network;
  searxngData = config.local.containers.searxng;
in
{
  options.local.containers.searxng = lib.mkOption { type = lib.types.attrs; };

  config = {
    containers.searxng = {
      autoStart = true;
      privateNetwork = true;
      macvlans = [ containerData.hostInterface ];
      bindMounts = {
        # Legacy host-local secret path. Create /etc/searx-env on the host with:
        #   SEARX_SECRET_KEY=$(openssl rand -hex 32)
        #   chmod 600 /etc/searx-env
        "/run/secrets/searx-env" = {
          hostPath = searxngData.environmentHostPath;
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
                address = searxngData.address;
                prefixLength = searxngData.prefixLength;
              }
            ];
          };
          networking.defaultGateway = containerData.defaultGateway;
          networking.nameservers = containerData.nameservers;

          services.searx = {
            enable = true;
            configureUwsgi = true;
            redisCreateLocally = true;
            environmentFile = "/run/secrets/searx-env";
            uwsgiConfig = {
              http = "127.0.0.1:8888";
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

          services.caddy = {
            enable = true;
            virtualHosts.":80" = {
              extraConfig = ''
                reverse_proxy 127.0.0.1:8888
              '';
            };
          };

          networking.firewall.allowedTCPPorts = [ 80 ];

          system.stateVersion = "25.11";
        };
    };
  };
}
