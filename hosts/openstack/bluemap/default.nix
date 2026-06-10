{ ... }:
{
  imports = [
    ../../../profiles/nixos/openstack/bluemap
    ./hardware-configuration.nix
    ./host-data.nix
  ];
}
