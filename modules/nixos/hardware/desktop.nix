{ ... }:
{
  imports = [
    ./cachyos-kernel.nix
    ./nvidia.nix
    ./swap.nix
    ./pentablet.nix
    ./mounts.nix
    ./scanner.nix
  ];
}
