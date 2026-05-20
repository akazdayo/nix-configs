{ ... }:
{
  imports = [
    ./nix-core.nix
    ./nh.nix
  ];

  services.cloud-init.enable = true;
}
