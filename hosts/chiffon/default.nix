{ inputs, hostMeta, ... }:
{
  imports = [
    ./homebrew.nix
    ../../modules/darwin/system.nix
    ../../modules/darwin/networking.nix
    ../../modules/darwin/user.nix
    ../../modules/darwin/secrets.nix
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

  system.stateVersion = 6;
}
