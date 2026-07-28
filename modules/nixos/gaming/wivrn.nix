{ inputs, pkgs, ... }:
{
  nixpkgs.overlays = [ inputs.wivrn-nix.overlays.default ];

  services.wivrn = {
    enable = true;
    openFirewall = true;
    autoStart = true;
    steam.importOXRRuntimes = true;
    package = pkgs.wivrn.override { cudaSupport = true; };
  };
}
