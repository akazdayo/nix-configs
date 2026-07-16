{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = [
        "Monaspace Radon Var"
        "Noto Sans CJK JP"
      ];
      gtk-titlebar = false;
      background-opacity = 0.7;
    };
  };
}
