{ hostMeta, ... }:
let
  hostData = {
    networking = {
      primaryInterface = "enp1s0";
    };

    fileSystems.minecraftData = {
      mountPoint = "/srv/minecraft";
      device = "/dev/disk/by-label/minecraft-data";
      fsType = "ext4";
    };

    minecraft = {
      dataDir = "/srv/minecraft";

      smp = {
        serverPort = 25566;
        jvmOpts = "-Xms1G -Xmx2G";
      };

      creative = {
        serverPort = 25568;
        jvmOpts = "-Xms1G -Xmx2G";
      };
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
