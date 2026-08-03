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
    ../../modules/nixos/boot/grub.nix
    ../../modules/nixos/security.nix
    ../../modules/nixos/sops.nix
    ../../modules/nixos/caddy.nix
    ../../modules/nixos/minecraft/velocity.nix
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
    sops.pcscd = true;
    caddy.virtualHosts.bluemap = {
      hostname = ":80";
      upstream = "138.252.25.159:8100";
      openFirewall = true;
    };
    minecraft.velocity = {
      serverPort = 25565;
      voiceChatPort = 24454;
      jvmOpts = "-Xms512M -Xmx1G";
      primaryInterface = "enp1s0";
      internalIp = "138.252.25.159";
      smpPort = 25566;
      creativePort = 25568;
      sopsFile = ../../secrets/openstack/gateway/velocity.yaml;
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
