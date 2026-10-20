{
  hostMeta,
  lib,
  pkgs,
  ...
}:
{
  services.desktopManager.plasma6.enable = true;
  programs.kde-pim.enable = false;

  security.pam.services = {
    login.kwallet.enable = lib.mkForce false;
    kde.kwallet.enable = lib.mkForce false;
  };
  home-manager.users.${hostMeta.primaryUser}.xdg.configFile."kwalletrc".text = ''
    [Wallet]
    Enabled=false
  '';

  # デスクトップの基本機能は残し、付属アプリは既存のものを使う。
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    ark
    elisa
    gwenview
    okular
    kate
    ktexteditor
    khelpcenter
    konsole
    dolphin
    dolphin-plugins
    baloo-widgets
    spectacle
    ffmpegthumbs
    krdp
    discover
    qrca
    kwin-x11
    plasma-workspace-wallpapers
    plasma-keyboard
    qtvirtualkeyboard
  ];

  # GNOME / Niri と併存するため Plasma 用のポータル設定も追加する。
  xdg.portal.configPackages = [ pkgs.kdePackages.plasma-workspace ];
}
