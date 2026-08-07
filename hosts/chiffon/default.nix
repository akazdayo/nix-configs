{ inputs, hostMeta, ... }:
{
  imports = [
    ./homebrew.nix
    ../../modules/darwin/system.nix
    ../../modules/darwin/networking.nix
    ../../modules/darwin/user.nix
    ../../modules/darwin/secrets.nix
    ../../modules/nixos/nix/cache.nix
  ];

  home-manager.users.${hostMeta.primaryUser} = {
    imports = [
      inputs.sops-nix.homeManagerModules.default
      ../../home/programs/git.nix
      ../../home/programs/ssh.nix
      ../../home/programs/nushell.nix
      ../../home/programs/zellij.nix
      ../../home/programs/nixvim
      ../../home/programs/secrets.nix
      ../../home/packages/core.nix
      ../../home/packages/development.nix
      ../../home/packages/darwin.nix
      ../../home/packages/llm.nix
    ];
    programs.ssh.settings."192.168.11.50" = {
      header = "Host 192.168.11.50";
      User = "akazdayo";
      IdentityFile = "~/.ssh/id_ed25519_sk_rk";
      IdentityAgent = "none";
    };
    home.stateVersion = "25.11";
  };

  local = {
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
      alwaysAllowSubstitutes = true;
    };
  };

  system.stateVersion = 6;
}
