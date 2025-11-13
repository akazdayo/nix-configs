{
  pkgs,
  pkgs-xr,
  ...
}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages =
      (with pkgs; [
        proton-ge-bin
      ])
      ++ (with pkgs-xr; [
        # nixpkgs-xr
        proton-ge-rtsp-bin
      ]);
  };
}
