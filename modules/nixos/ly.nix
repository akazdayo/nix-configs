{ ... }:
{
  # GNOME / Niri の選択はログイン画面のセッション欄から行う。
  services.displayManager.ly = {
    enable = true;
    x11Support = false;
    settings = {
      load = false;
      save = false;
    };
  };
}
