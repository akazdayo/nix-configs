{ ... }:
{
  imports = [
    ../../modules/nixos/system/nix-core.nix
    ../../modules/nixos/system/nix-ld.nix
    ../../modules/nixos/system/nh.nix
    ../../modules/nixos/users/wsl.nix
    ../../modules/nixos/wsl/wsl.nix
  ];

  system.stateVersion = "25.11";
}
