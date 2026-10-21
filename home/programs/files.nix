{ pkgs, lib, ... }:
{
  home.file = {
    ".bashrc".source = ../../dotfiles/bashrc;
    ".bash_profile".source = ../../dotfiles/bash_profile;
    ".config/git/ignore".source = ../../dotfiles/gitignore;
    ".agents/skills/nix-flake-safety".source = ../../.agents/skills/nix-flake-safety;
    ".config/starship.toml".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/starship/starship/5bb1f207be78fd4adb13d05e4d8b4a368870b2be/docs/public/presets/toml/catppuccin-powerline.toml";
      sha256 = "sha256-l4XVGxDFMzup1qjvRYVi/utUEmwVm/gpVYIJkCfBCpM=";
    };
  };
}
