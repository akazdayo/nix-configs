{ inputs, hostMeta, ... }:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../modules/nixos/nix/core.nix
    ../../modules/nixos/nix/nix-ld.nix
    ../../modules/nixos/nix/nh.nix
    ../../modules/nixos/nix/cache.nix
    ../../modules/nixos/users/primary.nix
    ../../modules/nixos/wsl.nix
  ];

  networking.hostName = hostMeta.hostName;

  local = {
    nh.flake = hostMeta.flakeRoot;
    nix.cache = {
      substituters = [
        "https://attic.odango.app/odango"
        "https://cache.numtide.com"
        "https://akazdayo-nixos-config.cachix.org"
      ];
      trustedPublicKeys = [
        "odango:8blIZl1xfwVCsNo2vUDYP5OXgwWAcC5WJDI1HuoeKLk="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "akazdayo-nixos-config.cachix.org-1:beIgz4A31qNo0DBTEaTGbNy/xGuNJZZpH0n3BDc+JVk="
      ];
    };
    users.primary = {
      name = hostMeta.primaryUser;
      extraGroups = [
        "wheel"
        "docker"
      ];
    };
    wsl.defaultUser = hostMeta.primaryUser;
  };

  home-manager.users.${hostMeta.primaryUser} = {
    imports = [
      ../../home/programs/git.nix
      ../../home/programs/nushell.nix
      ../../home/programs/nixvim
      ../../home/packages/core.nix
      ../../home/packages/llm.nix
    ];
    home.stateVersion = "25.11";
  };

  system.stateVersion = "25.11";
}
