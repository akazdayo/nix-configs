{ pkgs, hostMeta, ... }:
let
  isDesktop = hostMeta.hostName == "nixos";
in
{
  home.packages = (
    if isDesktop then
      (with pkgs; [
        devenv
        godot_4
        unityhub
        immich-go
        nvtopPackages.nvidia
      ])
    else
      (with pkgs; [
        pnpm
        bun
        nodejs_24
      ])
  );
}
