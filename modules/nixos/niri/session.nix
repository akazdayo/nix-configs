{ pkgs, pkgs-unstable, ... }:
{
  # XDGポータル(スクリーンシェア、ファイルピッカー)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    # niri-portals.conf を使用してポータルの優先順位を設定
    configPackages = [ pkgs-unstable.niri ];
  };

  # 認証ダイアログ用
  security.polkit.enable = true;

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    # GNOME Shell は認証エージェントを内蔵しているため Niri / labwc に限定する。
    wantedBy = [
      "niri.service"
      "labwc-session.target"
    ];
    partOf = [
      "niri.service"
      "labwc-session.target"
    ];
    after = [
      "niri.service"
      "labwc-session.target"
    ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
