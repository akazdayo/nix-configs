# This is a simple wrapper that imports the host-specific configuration
# For modular configuration, see hosts/nixos/default.nix
{...}: {
  imports = [
    ./hosts/nixos
  ];
}
