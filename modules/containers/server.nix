{ ... }:
{
  imports = [
    ./immich.nix
    ./nextcloud.nix
    ./pihole-unbound.nix
    ./searxng.nix
  ];

  virtualisation.oci-containers.backend = "docker";
}
