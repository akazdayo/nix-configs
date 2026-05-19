{ hostMeta, ... }:
let
  hostData = {
    networking = {
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];
      unmanagedInterfaces = [ "eno1" ];
      primaryInterface = "eno1";
      address = "192.168.11.50";
      prefixLength = 24;
      defaultGateway = "192.168.11.1";
      macvlanShim = {
        name = "mv-shim";
        parentInterface = "eno1";
        address = "192.168.11.70";
        prefixLength = 32;
        routeAddresses = [
          "192.168.11.65"
        ];
      };
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

      attic = {
        address = "192.168.11.65";
        prefixLength = 24;
        hostName = "attic";
        apiDomain = "attic.odango.app";
        hostDataRoot = "/var/lib/attic-container";
        # sops-nix decrypts to /run/secrets/atticd-env on host;
        # bind-mounted read-only into the container.
        environmentHostPath = "/run/secrets/atticd-env";
      };
    };

    # Cloudflare Tunnel: ingress rules declared here; DNS routes managed externally.
    # Replace tunnelUuid after running `cloudflared tunnel create <name>`.
    cloudflared = {
      tunnelUuid = "9a22fd7b-44dd-4459-a360-52a5226b8216";
      ingress = {
        attic = {
          hostname = "attic.odango.app";
          service = "http://192.168.11.65:8080";
        };
      };
    };
  };
in
{
  _module.args.hostData = hostData;
}
