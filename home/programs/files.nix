{pkgs-xr, ...}: {
  home.file = {
    ".bashrc".source = ../../dotfiles/bashrc;
    ".bash_profile".source = ../../dotfiles/bash_profile;
    ".config/zed/settings.json".source = ../../dotfiles/zed_settings.json;
    ".local/share/Steam/compatibilitytools.d/proton-ge-rtsp".source = pkgs-xr.proton-ge-rtsp-bin;
  };
}
