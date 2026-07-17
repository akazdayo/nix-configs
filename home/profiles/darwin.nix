{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.default
    ../programs/git.nix
    ../programs/ssh.nix
    ../programs/nushell.nix
    ../programs/zellij.nix
    ../programs/nixvim
    ../packages/core.nix
    ../packages/development.nix
    ../packages/darwin.nix
    ../packages/llm.nix
    ../programs/secrets.nix
  ];

  home.stateVersion = "25.11";
}
