{ ... }:
{
  imports = [
    ./immich.nix
    ./nextcloud.nix
    ./pihole-unbound.nix
    ./searxng.nix
    ./attic.nix
  ];

  virtualisation.oci-containers.backend = "docker";
}
