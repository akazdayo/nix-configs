{ inputs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default
    inputs.sops-nix.homeManagerModules.default
    ../programs/git.nix
    ../programs/ssh.nix
    ../programs/files.nix
    ../programs/flameshot.nix
    ../packages/core.nix
    ../packages/desktop.nix
    ../packages/development.nix
    ../packages/media.nix
    ../packages/wayland.nix
    ../packages/gaming.nix
    ../packages/llm.nix
    ../programs/noctalia.nix
    ../programs/niri.nix
    ../programs/cursor.nix
    ../programs/ghostty.nix
    ../programs/nushell.nix
    ../programs/zellij.nix
    ../programs/nixvim
    ../programs/obs.nix
    ../programs/secrets.nix
    ../programs/wakatime.nix
    ../programs/zoom.nix
  ];
  home.sessionVariables.EDITOR = "nvim";
  home.stateVersion = "25.11";
}
