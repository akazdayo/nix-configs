{ ... }:
{
  imports = [
    ../../profiles/nixos/server.nix
    ./hardware-configuration.nix
    ./host-data.nix
  ];
}
