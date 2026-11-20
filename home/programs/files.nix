{ ... }:
{
  home.file = {
    ".bashrc".source = ../../dotfiles/bashrc;
    ".bash_profile".source = ../../dotfiles/bash_profile;
    ".config/git/ignore".source = ../../dotfiles/gitignore;
    ".agents/skills/nix-flake-safety".source = ../../.agents/skills/nix-flake-safety;
  };
}
