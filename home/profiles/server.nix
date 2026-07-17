{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.default
    ../programs/git.nix
    ../programs/nushell.nix
    ../programs/zellij.nix
    ../programs/nixvim
    ../packages/core.nix
    ../packages/server.nix
    ../programs/secrets.nix
  ];
  home.stateVersion = "25.11";
}
