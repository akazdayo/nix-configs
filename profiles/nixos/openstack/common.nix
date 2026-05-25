{ ... }:
{
  imports = [
    ../../../modules/nixos/boot/openstack.nix
    ../../../modules/nixos/system/openstack.nix
    ../../../modules/nixos/networking/openstack.nix
    ../../../modules/nixos/users/openstack.nix
  ];

  system.stateVersion = "25.11";
}
