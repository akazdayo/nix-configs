{ ... }:
{
  imports = [
    ../../../profiles/nixos/openstack/attic
    ./hardware-configuration.nix
    ./host-data.nix
  ];
}
