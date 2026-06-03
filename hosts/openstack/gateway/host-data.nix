{ hostMeta, ... }:
let
  hostData = {
    networking = {
      primaryInterface = "enp1s0";
    };

    velocity = {
      # Port for Velocity to listen on (public-facing).
      serverPort = 25565;
      voiceChatPort = 24454;
      jvmOpts = "-Xms512M -Xmx1G";
    };

    minecraft = {
      internalIp = "138.252.25.159";

      smp = {
        serverPort = 25566;
      };

      creative = {
        serverPort = 25568;
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
