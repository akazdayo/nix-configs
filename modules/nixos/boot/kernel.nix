{ pkgs-unstable, ... }:
{
  boot.kernelPackages = pkgs-unstable.linuxPackages_latest;
}
