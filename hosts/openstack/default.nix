{ ... }:
{
  imports = [
    ../../profiles/nixos/openstack.nix
    ./hardware-configuration.nix
    ./host-data.nix
  ];
}
