{ ... }:
{
  imports = [
    ../../../profiles/nixos/openstack/gateway
    ./hardware-configuration.nix
    ./host-data.nix
  ];
}
