{ pkgs, ... }:
{
  # ログイン画面に GNOME Wayland セッションを追加する。
  services.desktopManager.gnome.enable = true;

  # Niri 側の設定と併存させ、GNOME 用のポータル選択も提供する。
  xdg.portal.configPackages = [ pkgs.gnome-session ];
}
