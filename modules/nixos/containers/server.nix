{ ... }:
{
  imports = [
    ./immich.nix
    ./nextcloud.nix
    ./pihole-unbound.nix
    ./searxng.nix
    ./attic.nix
    ./obsidian-livesync.nix
  ];

  virtualisation.oci-containers.backend = "docker";
}
