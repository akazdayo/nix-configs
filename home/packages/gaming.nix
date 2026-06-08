{ pkgs, pkgs-unstable, ... }:
{
  home.packages =
    (with pkgs; [
      (prismlauncher.override {
        jdks = [
          jdk25
          jdk21
          jdk17
          jdk8
        ];
      })
      wlx-overlay-s
      alcom
      osu-lazer-bin
      wineWowPackages.stable # 64bit + 32bit対応
      winetricks
      vrcx
      protonup-qt
    ])
    ++ (with pkgs-unstable; [
      wayvr
      bs-manager
      tetrio-desktop
    ]);
}
