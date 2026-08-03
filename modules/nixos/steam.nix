{ pkgs, pkgs-unstable, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs-unstable; [
      proton-ge-bin
    ];
  };
}
