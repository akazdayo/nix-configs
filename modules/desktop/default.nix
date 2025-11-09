{...}: {
  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];

    displayManager.sessionCommands = ''
      xrandr --output DP-1 --mode 1920x1080 --rate 240
    '';
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  programs.dconf.enable = true;

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "akazdayo";

  # Workaround for GNOME autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
