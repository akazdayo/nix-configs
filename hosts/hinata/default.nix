{ inputs, hostMeta, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.sops-nix.nixosModules.default
    ../../modules/nixos/nix/core.nix
    ../../modules/nixos/nix/nix-ld.nix
    ../../modules/nixos/nix/nh.nix
    ../../modules/nixos/networking/ssh.nix
    ../../modules/nixos/networking/network-manager.nix
    ../../modules/nixos/networking/static-ipv4.nix
    ../../modules/nixos/networking/macvlan-shim.nix
    ../../modules/nixos/networking/tailscale.nix
    ../../modules/nixos/networking/wireguard.nix
    ../../modules/nixos/locale/common.nix
    ../../modules/nixos/users/primary.nix
    ../../modules/nixos/users/deploy.nix
    ../../modules/nixos/boot/systemd-boot.nix
    ../../modules/nixos/sops.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/cloudflared.nix
    ../../modules/nixos/litellm.nix
    ../../modules/nixos/containers/network.nix
    ../../modules/nixos/containers/immich.nix
    ../../modules/nixos/containers/nextcloud.nix
    ../../modules/nixos/containers/pihole-unbound.nix
    ../../modules/nixos/containers/searxng.nix
    ../../modules/nixos/containers/attic.nix
  ];

  networking.hostName = hostMeta.hostName;

  local = {
    nh.flake = hostMeta.flakeRoot;
    users = {
      primary = {
        name = hostMeta.primaryUser;
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "video"
          "render"
          "input"
        ];
        authorizedKeys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIuYLePldOwgtFXwo0sw48rBVzX2zHjzGshFq4V9xwMLAAAABHNzaDo= somanoda@25N1103630nodasoma.local"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrvifm9j0kjjoEUWf+QeFxQgdA9XPYc/VRyS9oPL+X5"
        ];
        trustedNixUser = true;
      };
      deploy.authorizedKeys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIuYLePldOwgtFXwo0sw48rBVzX2zHjzGshFq4V9xwMLAAAABHNzaDo= somanoda@25N1103630nodasoma.local"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrvifm9j0kjjoEUWf+QeFxQgdA9XPYc/VRyS9oPL+X5"
      ];
    };
    networking = {
      networkManager = {
        nameservers = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };
      staticIPv4 = {
        interface = "eno1";
        address = "192.168.11.50";
        prefixLength = 24;
        defaultGateway = "192.168.11.1";
      };
      macvlanShim = {
        name = "mv-shim";
        parentInterface = "eno1";
        address = "192.168.11.70";
        routeAddresses = [ "192.168.11.65" ];
      };
      wireguard = {
        sopsFile = ../../secrets/common/wireguard.yaml;
        secretKey = "maril_wireguard_sk";
        ips = [ "10.0.10.3/24" ];
        peers = [
          {
            publicKey = "p0cQLr7R7xqDYHH/eZSz2wAMjJGF+NGLFocMXXs/dEQ=";
            endpoint = "maril.blue:51821";
            allowedIPs = [ "10.0.10.0/24" ];
            persistentKeepalive = 25;
          }
        ];
      };
    };
    sops = {
      pcscd = true;
      yubikeyPlugin = true;
      keyFile = "/home/${hostMeta.primaryUser}/.config/sops/age/keys.txt";
      ageKeyCommandEnvironment = "$HOME/.config/sops/age/yubikey-priority.sh";
    };
    cloudflared = {
      tunnelUuid = "9a22fd7b-44dd-4459-a360-52a5226b8216";
      credentialsSopsFile = ../../secrets/hinata/cloudflared.yaml;
      ingress = {
        attic = {
          hostname = "attic.odango.app";
          service = "http://192.168.11.65:8080";
        };
        litellm = {
          hostname = "llm.odango.app";
          service = "http://192.168.11.50:4000";
        };
      };
    };
    litellm = {
      host = "192.168.11.50";
      port = 4000;
      environmentSopsFile = ../../secrets/hinata/litellm.yaml;
      chatgptAuthSopsFile = ../../secrets/hinata/litellm-chatgpt.yaml;
    };
    containers = {
      network = {
        hostInterface = "eno1";
        containerInterface = "mv-eno1";
        defaultGateway = "192.168.11.1";
        nameservers = [ "1.1.1.1" ];
      };
      immich = {
        dataRoot = "/var/lib/immich-container";
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
        # Legacy secret managed outside sops-nix.
        adminPassHostPath = "/etc/nextcloud-adminpass";
      };
      searxng = {
        address = "192.168.11.64";
        prefixLength = 24;
        # Legacy secret managed outside sops-nix.
        environmentHostPath = "/etc/searx-env";
      };
      attic = {
        address = "192.168.11.65";
        prefixLength = 24;
        hostName = "attic";
        apiDomain = "attic.odango.app";
        dataRoot = "/var/lib/attic-container";
        environmentSopsFile = ../../secrets/hinata/attic.yaml;
      };
    };
  };

  home-manager.users.${hostMeta.primaryUser} = {
    imports = [
      inputs.sops-nix.homeManagerModules.default
      ../../home/programs/git.nix
      ../../home/programs/nushell.nix
      ../../home/programs/zellij.nix
      ../../home/programs/nixvim
      ../../home/programs/secrets.nix
      ../../home/packages/core.nix
    ];
    home.stateVersion = "25.11";
  };

  virtualisation.oci-containers.backend = "docker";
  system.stateVersion = "25.11";
}
