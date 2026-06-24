{ pkgs, pkgs-unstable, ... }:
{
  imports = [
    ./firefox.nix
    ./printing.nix
    ./sunshine.nix
    ./wayland/login.nix
    ./wayland/niri.nix
    ./wayland/variable.nix
    ./zoom.nix
  ];

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
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
