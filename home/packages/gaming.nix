{ pkgs, pkgs-unstable, ... }:
{
  home.packages =
    (with pkgs; [
      (prismlauncher.override {
        jdks = [
          jdk25
        ];
      })
      osu-lazer-bin
      wineWow64Packages.stable # 64bit + 32bit対応
      winetricks
      vrcx
    ])
    ++ (with pkgs-unstable; [
      wayvr
    ]);
}
