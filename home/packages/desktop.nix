{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nextcloud-client
    xdg-utils
    slack
    alacritty
    libreoffice
    signal-desktop
    mattermost-desktop
    termius
    tor-browser
    google-chrome
    nautilus
    unar
    obsidian
    vesktop
    wireguard-tools
  ];
}
