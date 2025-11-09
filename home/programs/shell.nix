{...}: {
  home.file = {
    ".bashrc".source = ../../dotfiles/bashrc;
    ".bash_profile".source = ../../dotfiles/bash_profile;
  };
}
