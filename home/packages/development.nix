{ pkgs, hostMeta, ... }:
let
  isDesktop = hostMeta.hostName == "milk";
in
{
  home.packages = (
    if isDesktop then
      (with pkgs; [
        devenv
        godot_4
        unityhub
        immich-go
        pnpm
      ])
    else
      (with pkgs; [
        pnpm
        bun
        nodejs_24
      ])
  );
}
