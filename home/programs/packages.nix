{pkgs, ...}: {
  home.packages = with pkgs; [
    vim
    vesktop
    zed-editor
    osu-lazer-bin
    ghostty
    nixd
    nil
    alejandra
    starship
    direnv
    lmstudio
    fastfetch
    tree
    wlx-overlay-s
  ];
}
