{ ... }:
{
  imports = [
    ../common.nix
    ../../../../modules/nixos/services/atticd.nix
    ../../../../modules/nixos/secrets/attic.nix
  ];
}
