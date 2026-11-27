{ inputs, pkgs, ... }:
let
  proton = inputs.proton-nix.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.steam = {
    enable = true;
    extraCompatPackages = [
      proton.proton-ge-bin
      proton.proton-rtsp-bin
    ];
    dedicatedServer.openFirewall = true;
  };
}
