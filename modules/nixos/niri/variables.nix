{ ... }:
{
  # Wayland環境変数
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Electron (Vesktop等)
    MOZ_ENABLE_WAYLAND = "1"; # Firefox
    TZ = "Asia/Tokyo";

    # fcitx5 IME設定
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    GLFW_IM_MODULE = "ibus"; # ゲーム用
  };
}
