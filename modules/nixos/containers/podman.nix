{ config, lib, ... }:
let
  podmanData = config.local.containers.podman;
in
{
  options.local.containers.podman = {
    user = lib.mkOption {
      type = lib.types.str;
    };
    containers = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = { };
    };
  };

  config = {
    users.users.${podmanData.user} = {
      autoSubUidGidRange = true;
      linger = true;
    };

    virtualisation.oci-containers = {
      backend = "podman";
      containers = lib.mapAttrs (
        _: container:
        container
        // {
          podman = (container.podman or { }) // {
            user = podmanData.user;
          };
        }
      ) podmanData.containers;
    };
  };
}
