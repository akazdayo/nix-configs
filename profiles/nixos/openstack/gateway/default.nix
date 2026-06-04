{ ... }:
{
  imports = [
    ../common.nix
    ../../../../modules/nixos/gaming/velocity-server.nix
    ../../../../modules/nixos/networking/caddy.nix
  ];
}
