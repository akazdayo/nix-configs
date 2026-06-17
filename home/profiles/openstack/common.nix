{ ... }:
{
  imports = [
    ../../programs/git.nix
    ../../programs/nushell.nix
    ../../packages/core.nix
  ];

  home.stateVersion = "25.11";
}
