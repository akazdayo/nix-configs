{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-skk
      fcitx5-gtk
      qt6Packages.fcitx5-with-addons # Waylandサポート
      qt6Packages.fcitx5-configtool # GUI設定ツール
    ];
  };

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    ipafont
    kochi-substitute
    inter
    monaspace
    nerd-fonts.fira-code
    fira-code
  ];
  fonts.fontDir.enable = true;
}
