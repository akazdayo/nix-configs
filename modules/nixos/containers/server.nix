{ ... }:
{
  imports = [
    ./immich.nix
    ./nextcloud.nix
    ./pihole-unbound.nix
    ./searxng.nix
    ./niks3.nix
    ./rustfs.nix
  ];

  virtualisation.oci-containers.backend = "docker";
}
