{
  pkgs,
  pkgs-stable,
  pkgs-xr,
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
      spotify
      ollama-cuda
      google-chrome
      vrcx
      _1password-gui
      tor-browser
      gh
      vrc-get
      unityhub
      claude-code
      bs-manager
      nix-index
      wl-clipboard
      alcom
      wineWowPackages.stable # 64bit + 32bit対応
      winetricks
      slack
    ])
    ++ (with pkgs-stable; [
      # stable 25.05
    ])
    ++ (with pkgs-xr; [
      # nixpkgs-xr
    ]);
}
