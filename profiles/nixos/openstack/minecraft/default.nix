{ ... }:
{
  imports = [
    ../common.nix
    ../../../../modules/nixos/hardware/minecraft-data-volume.nix
    ../../../../modules/nixos/gaming/minecraft-server.nix
  ];
}
