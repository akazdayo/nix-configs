{ ... }:
{
  imports = [
    ../../modules/nixos/boot/server.nix
    ../../modules/nixos/system/server.nix
    ../../modules/nixos/networking/server.nix
    ../../modules/nixos/locale/server.nix
    ../../modules/nixos/users/server.nix
    ../../modules/nixos/users/deploy.nix
    ../../modules/nixos/virtualization/server.nix
    ../../modules/nixos/containers/server.nix
    ../../modules/nixos/secrets/server.nix
  ];

  system.stateVersion = "25.11";
}
