{ ... }:
{
  # Noctalia Shell設定
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings.shell.launch_apps_as_systemd_services = true;
  };
}
