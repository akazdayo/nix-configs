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
    fcitx5.settings.inputMethod = {
      "Groups/0" = {
        Name = "デフォルト";
        "Default Layout" = "us";
        DefaultIM = "skk";
      };
      "Groups/0/Items/0" = {
        Name = "keyboard-us";
        Layout = "";
      };
      "Groups/0/Items/1" = {
        Name = "skk";
        Layout = "";
      };
      GroupOrder."0" = "デフォルト";
    };
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
