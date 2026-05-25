{ ... }:
{
  imports = [
    ../../programs/git.nix
    ../../programs/nushell.nix
    ../../programs/nixvim
    ../../packages/core.nix
  ];

  home.stateVersion = "25.11";
}
