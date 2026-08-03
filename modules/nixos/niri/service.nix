{ pkgs-unstable, ... }:
{
  # niri有効化
  programs.niri = {
    enable = true;
    package = pkgs-unstable.niri;
  };

  # Noctalia/niri依存サービス
  hardware.bluetooth.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}
