{
  config,
  lib,
  pkgs,
  ...
}:
let
  screenshotsDir = "${config.home.homeDirectory}/Pictures/Screenshots";
in
{
  home.packages = with pkgs; [
    grim
  ];

  home.activation.createFlameshotScreenshotsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${lib.escapeShellArg screenshotsDir}
  '';

  services.flameshot = {
    enable = true;
    settings = {
      General = {
        savePath = screenshotsDir;
        disabledTrayIcon = true;
        showStartupLaunchMessage = false;
        showDesktopNotification = true;
        showAbortNotification = false;
        useGrimAdapter = true;
        disabledGrimWarning = true;
      };
    };
  };
}
