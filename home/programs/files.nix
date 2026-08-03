{ pkgs, lib, ... }:
{
  home.file = {
    ".bashrc".source = ../../dotfiles/bashrc;
    ".bash_profile".source = ../../dotfiles/bash_profile;
    ".config/git/ignore".source = ../../dotfiles/gitignore;
    ".agents/skills/nix-flake-safety".source = ../../.agents/skills/nix-flake-safety;
    ".config/starship.toml".source = pkgs.fetchurl {
      url = "https://starship.rs/presets/toml/catppuccin-powerline.toml";
      sha256 = "sha256-wjdG5MJJA1rQL0KIbpR2Q+gLrmZDqkFwo7RxO+pf68s=";
    };
  };
}
