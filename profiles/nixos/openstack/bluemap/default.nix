{ ... }:
{
  imports = [
    ../common.nix
    ../../../../modules/nixos/hardware/bluemap-data-volume.nix
    ../../../../modules/nixos/minecraft/bluemap-host.nix
  ];
}
