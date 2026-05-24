{ ... }:
{
  imports = [
    ../../../profiles/nixos/openstack/minecraft
    ./hardware-configuration.nix
    ./host-data.nix
  ];
}
