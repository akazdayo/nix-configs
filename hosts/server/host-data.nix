{ hostMeta, ... }:
let
  hostData = {
    networking = {
      nameservers = [ "192.168.11.62" ];
      unmanagedInterfaces = [ "eno1" ];
      primaryInterface = "eno1";
      address = "192.168.11.50";
      prefixLength = 24;
      defaultGateway = "192.168.11.1";
    };

    users.${hostMeta.primaryUser}.authorizedKeys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIuYLePldOwgtFXwo0sw48rBVzX2zHjzGshFq4V9xwMLAAAABHNzaDo= somanoda@25N1103630nodasoma.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrvifm9j0kjjoEUWf+QeFxQgdA9XPYc/VRyS9oPL+X5"
    ];

    containers = {
      hostInterface = "eno1";
      containerInterface = "mv-eno1";
      defaultGateway = "192.168.11.1";
      nameservers = [ "1.1.1.1" ];

      immich = {
        hostDataRoot = "/var/lib/immich-container";
        hostName = "immich";
        address = "192.168.11.61";
        prefixLength = 24;
        externalDomain = "http://192.168.11.61:2283";
      };

      piholeUnbound = {
        address = "192.168.11.62";
        prefixLength = 24;
        hosts = [
          "192.168.11.62 dns.home.arpa"
          "192.168.11.63 nas.home.arpa"
          "192.168.11.64 search.home.arpa"
        ];
      };

      nextcloud = {
        address = "192.168.11.63";
        prefixLength = 24;
        trustedDomains = [ "nas.home.arpa" ];
        # Legacy host-local secret path. Keep managed outside sops-nix for now.
        adminPassHostPath = "/etc/nextcloud-adminpass";
      };

      searxng = {
        address = "192.168.11.64";
        prefixLength = 24;
        # Legacy host-local secret path. Keep managed outside sops-nix for now.
        environmentHostPath = "/etc/searx-env";
      };
    };

    # Cloudflare Tunnel: ingress rules declared here; DNS routes managed externally.
    # Replace tunnelUuid after running `cloudflared tunnel create <name>`.
    cloudflared = {
      tunnelUuid = "00000000-0000-0000-0000-000000000000";
      ingress = {
        immich = {
          hostname = "photos.odango.app";
          service = "http://192.168.11.61:2283";
        };
      };
    };
  };
in
{
  _module.args.hostData = hostData;
}
