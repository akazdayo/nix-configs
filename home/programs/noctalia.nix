{ lib, ... }:
{
  # Noctalia Shell設定
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings.shell.launch_apps_as_systemd_services = true;
  };

  # GNOME では起動せず、Niri の終了とともに停止する。
  systemd.user.services.noctalia = {
    Unit.PartOf = lib.mkForce [ "niri.service" ];
    Unit.After = lib.mkForce [ "niri.service" ];
    Install.WantedBy = lib.mkForce [ "niri.service" ];
  };
}
