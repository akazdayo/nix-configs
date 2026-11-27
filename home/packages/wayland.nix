{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard

    # Wayland共通ツール
    brightnessctl # 輝度調整
    playerctl # メディアコントロール
    pavucontrol # 音量設定GUI
    networkmanagerapplet # ネットワーク管理
    blueman # Bluetooth管理
    nwg-look # GTKテーマ設定
    libsForQt5.qt5ct # Qtテーマ設定
    kdePackages.qt6ct
  ];
}
