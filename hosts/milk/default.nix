{ inputs, hostMeta, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.sops-nix.nixosModules.default
    inputs.nix-flatpak.nixosModules.nix-flatpak
    ../../modules/nixos/nix/core.nix
    ../../modules/nixos/nix/nix-ld.nix
    ../../modules/nixos/nix/nh.nix
    ../../modules/nixos/nix/cache.nix
    ../../modules/nixos/networking/ssh.nix
    ../../modules/nixos/networking/network-manager.nix
    ../../modules/nixos/networking/tailscale.nix
    ../../modules/nixos/networking/wireguard.nix
    ../../modules/nixos/locale/common.nix
    ../../modules/nixos/locale/japanese-input.nix
    ../../modules/nixos/users/primary.nix
    ../../modules/nixos/hardware/swap.nix
    ../../modules/nixos/hardware/file-systems.nix
    ../../modules/nixos/hardware/cachyos-kernel.nix
    ../../modules/nixos/hardware/nvidia.nix
    ../../modules/nixos/hardware/pentablet.nix
    ../../modules/nixos/hardware/scanner.nix
    ../../modules/nixos/boot/lanzaboote.nix
    ../../modules/nixos/niri/login.nix
    ../../modules/nixos/niri/service.nix
    ../../modules/nixos/niri/session.nix
    ../../modules/nixos/niri/variables.nix
    ../../modules/nixos/sops.nix
    ../../modules/nixos/wakatime.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/packages.nix
    ../../modules/nixos/one-password.nix
    ../../modules/nixos/firefox.nix
    ../../modules/nixos/printing.nix
    ../../modules/nixos/sunshine.nix
    ../../modules/nixos/zoom.nix
    ../../modules/nixos/pipewire.nix
    ../../modules/nixos/flatpak.nix
    ../../modules/nixos/steam.nix
    ../../modules/nixos/wivrn.nix
  ];

  networking.hostName = hostMeta.hostName;

  local = {
    nh.flake = hostMeta.flakeRoot;
    nix.cache = {
      substituters = [
        "https://cache.numtide.com"
        "https://akazdayo-nixos-config.cachix.org"
      ];
      trustedPublicKeys = [
        "main:p1I0gblo5KOxd64LCmeOmENhGx/fRCVp5CS4aOQGY6w="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "akazdayo-nixos-config.cachix.org-1:beIgz4A31qNo0DBTEaTGbNy/xGuNJZZpH0n3BDc+JVk="
      ];
    };
    users.primary = {
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
      ];
    };
    networking = {
      networkManager.nameservers = [ "192.168.11.62" ];
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
    hardware = {
      swap.device = "/var/lib/swapfile";
      fileSystems = {
        kioxia = {
          mountPoint = "/mnt/kioxia";
          device = "/dev/disk/by-uuid/7d2f187f-18cb-4c3b-8f5f-cccb8a337afc";
          fsType = "ext4";
          options = [
            "rw"
            "nofail"
          ];
        };
        windows = {
          mountPoint = "/mnt/windows";
          device = "/dev/disk/by-uuid/9660FCA060FC886F";
          fsType = "ntfs";
          options = [
            "rw"
            "uid=1000"
            "nofail"
          ];
        };
      };
    };
    boot.lanzaboote.pkiBundle = "/var/lib/sbctl";
    sops = {
      pcscd = true;
      yubikeyPlugin = true;
      ageKeyFileEnvironment = "$HOME/.config/sops/age/keys.txt";
      ageKeyCommandEnvironment = "$HOME/.config/sops/age/yubikey-priority.sh";
    };
    wakatime = {
      sopsFile = ../../secrets/milk/wakatime.yaml;
      owner = hostMeta.primaryUser;
    };
  };

  home-manager.users.${hostMeta.primaryUser} = {
    imports = [
      inputs.noctalia.homeModules.default
      inputs.sops-nix.homeManagerModules.default
      ../../home/programs/git.nix
      ../../home/programs/ssh.nix
      ../../home/programs/files.nix
      ../../home/programs/flameshot.nix
      ../../home/programs/noctalia.nix
      ../../home/programs/niri.nix
      ../../home/programs/cursor.nix
      ../../home/programs/ghostty.nix
      ../../home/programs/nushell.nix
      ../../home/programs/zellij.nix
      ../../home/programs/nixvim
      ../../home/programs/obs.nix
      ../../home/programs/secrets.nix
      ../../home/programs/wakatime.nix
      ../../home/programs/wivrn.nix
      ../../home/programs/zoom.nix
      ../../home/packages/core.nix
      ../../home/packages/desktop.nix
      ../../home/packages/development.nix
      ../../home/packages/media.nix
      ../../home/packages/wayland.nix
      ../../home/packages/gaming.nix
      ../../home/packages/llm.nix
    ];
    programs.ssh.settings."192.168.11.50" = {
      header = "Host 192.168.11.50";
      User = "akazdayo";
      IdentityFile = "~/.ssh/id_ed25519_sk_rk";
      IdentityAgent = "none";
    };
    home.sessionVariables.EDITOR = "nvim";
    home.stateVersion = "25.11";
  };

  system.stateVersion = "25.11";
}
