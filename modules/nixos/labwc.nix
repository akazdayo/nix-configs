{ pkgs, ... }:
{
  programs.labwc.enable = true;

  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config.labwc = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
    };
  };
}
