{ pkgs, pkgs-unstable, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    pkgs-unstable.cloudflared
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
