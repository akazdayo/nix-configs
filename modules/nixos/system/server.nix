{ hostMeta, ... }:
{
  imports = [
    ./nix-core.nix
    ./nix-ld.nix
    ./nh.nix
  ];

  nix.settings.trusted-users = [ hostMeta.primaryUser ];
}
