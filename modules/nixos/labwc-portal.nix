{ lib, pkgs, ... }:
{
  xdg.portal = {
    enable = true;
    wlr.settings.screencast = {
      chooser_type = "dmenu";
      chooser_cmd = "${lib.getExe pkgs.vicinae} dmenu --navigation-title 'Select a source to share'";
    };
    config.labwc = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
    };
  };
}
