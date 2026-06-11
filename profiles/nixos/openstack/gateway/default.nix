{ ... }:
{
  imports = [
    ../common.nix
    ../../../../modules/nixos/minecraft/velocity-server.nix
    ../../../../modules/nixos/networking/caddy.nix
  ];
}
