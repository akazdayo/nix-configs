{ ... }:
{
  imports = [
    ../../profiles/nixos/desktop.nix
    ./hardware-configuration.nix
    ./host-data.nix
  ];
}
