{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages =
    (with pkgs; [
      # 25.05
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
      obsidian
      xdg-utils
      zoom-us
    ])
    ++ (with pkgs-unstable; [
      # unstable
      claude-code
    ]);
}
