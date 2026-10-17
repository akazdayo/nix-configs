{ pkgs, ... }:
{
  # ログイン画面に GNOME Wayland セッションを追加する。
  services.desktopManager.gnome.enable = true;
  # 標準アプリ一式は入れず、必要なアプリは個別に管理する。
  services.gnome.core-apps.enable = false;

  # Niri 側の設定と併存させ、GNOME 用のポータル選択も提供する。
  xdg.portal.configPackages = [ pkgs.gnome-session ];
}
