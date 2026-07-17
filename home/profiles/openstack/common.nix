{ ... }:
{
  imports = [
    ../../programs/git.nix
    ../../programs/nushell.nix
    ../../programs/zellij.nix
    ../../packages/core.nix
  ];

  home.stateVersion = "25.11";
}
