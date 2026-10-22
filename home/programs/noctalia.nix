{ lib, ... }:
{
  # Noctalia Shell設定
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings.shell.launch_apps_as_systemd_services = true;
  };

  # Niri / labwc のセッションとともに起動・停止する。
  systemd.user.services.noctalia = {
    Unit.PartOf = lib.mkForce [
      "niri.service"
      "labwc-session.target"
    ];
    Unit.After = lib.mkForce [
      "niri.service"
      "labwc-session.target"
    ];
    Install.WantedBy = lib.mkForce [
      "niri.service"
      "labwc-session.target"
    ];
  };
}
