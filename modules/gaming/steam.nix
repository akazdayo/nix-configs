{pkgs, ...}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraPackages = with pkgs; [
      proton-ge-bin
    ];
  };
}
