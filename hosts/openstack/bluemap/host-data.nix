{ hostMeta, ... }:
let
  hostData = {
    networking = {
      primaryInterface = "enp1s0";
    };

    fileSystems.bluemapData = {
      mountPoint = "/srv/bluemap";
      device = "/dev/disk/by-label/bluemap-data";
      fsType = "ext4";
    };

    bluemap = {
      webRoot = "/srv/bluemap/web";
      httpPort = 80;
      rsyncPort = 873;
      rsyncModule = "bluemap-web";
      rsyncAllowedHosts = [ "138.252.25.159" ];
    };

    users.${hostMeta.primaryUser}.authorizedKeys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIuYLePldOwgtFXwo0sw48rBVzX2zHjzGshFq4V9xwMLAAAABHNzaDo= somanoda@25N1103630nodasoma.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrvifm9j0kjjoEUWf+QeFxQgdA9XPYc/VRyS9oPL+X5"
    ];

    users.deploy.authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0cl+EdTJh1MxftdC1ePO0C4oXajt7JzJrltg0kwR0U github-actions-deploy"
    ];
  };
in
{
  _module.args.hostData = hostData;
}
