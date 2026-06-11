{ ... }:
{
  imports = [
    ../common.nix
    ../../../../modules/nixos/hardware/swap.nix
    ../../../../modules/nixos/hardware/minecraft-data-volume.nix
    ../../../../modules/nixos/minecraft/minecraft-server.nix
  ];
}
