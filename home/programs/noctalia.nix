{ ... }:
{
  # Noctalia Shell設定
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = false;
  };
}
