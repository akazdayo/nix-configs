{ pkgs, ... }:
{
  home.packages = with pkgs; [
    xdg-utils
    slack
    libreoffice
    signal-desktop
    mattermost-desktop
    tor-browser
    google-chrome
    nautilus
    unar
    obsidian
    vesktop
    chromium
  ];
}
