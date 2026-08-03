{ inputs, hostMeta, ... }:
let
  primaryAuthorizedKeys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIuYLePldOwgtFXwo0sw48rBVzX2zHjzGshFq4V9xwMLAAAABHNzaDo= somanoda@25N1103630nodasoma.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrvifm9j0kjjoEUWf+QeFxQgdA9XPYc/VRyS9oPL+X5"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.sops-nix.nixosModules.default
    ../../modules/nixos/nix/core.nix
    ../../modules/nixos/nix/nh.nix
    ../../modules/nixos/networking/ssh.nix
    ../../modules/nixos/networking/dhcp.nix
    ../../modules/nixos/users/primary.nix
    ../../modules/nixos/users/deploy.nix
    ../../modules/nixos/hardware/swap.nix
    ../../modules/nixos/hardware/file-systems.nix
    ../../modules/nixos/boot/grub.nix
    ../../modules/nixos/security.nix
    ../../modules/nixos/sops.nix
    ../../modules/nixos/minecraft/server.nix
  ];

  networking.hostName = hostMeta.hostName;

  local = {
    nh.flake = hostMeta.flakeRoot;
    networking.dhcp.interface = "enp1s0";
    users = {
      primary = {
        name = hostMeta.primaryUser;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        authorizedKeys = primaryAuthorizedKeys;
      };
      deploy.authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0cl+EdTJh1MxftdC1ePO0C4oXajt7JzJrltg0kwR0U github-actions-deploy"
      ];
    };
    hardware = {
      swap = {
        device = "/var/lib/swapfile";
        size = 8 * 1024;
      };
      fileSystems.minecraftData = {
        mountPoint = "/srv/minecraft";
        device = "/dev/disk/by-label/minecraft-data";
        fsType = "ext4";
      };
    };
    sops.pcscd = true;
    minecraft.server = {
      dataDir = "/srv/minecraft";
      forwardingSecretSopsFile = ../../secrets/openstack/gateway/velocity.yaml;
      botApi = {
        httpPort = 8765;
        websocketPort = 8766;
      };
      smp = {
        serverPort = 25566;
        jvmOpts = "-Xms1G -Xmx2G";
        bluemap = {
          port = 8100;
          bindAddress = "0.0.0.0";
        };
      };
      creative = {
        serverPort = 25568;
        jvmOpts = "-Xms1G -Xmx2G";
      };
    };
  };

  home-manager.users.${hostMeta.primaryUser} = {
    imports = [
      ../../home/programs/git.nix
      ../../home/programs/nushell.nix
      ../../home/programs/zellij.nix
      ../../home/packages/core.nix
    ];
    home.stateVersion = "25.11";
  };

  system.stateVersion = "25.11";
}
