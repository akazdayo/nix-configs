{ hostMeta, ... }:
let
  hostData = {
    networking = {
      primaryInterface = "enp1s0";
    };

    users.${hostMeta.primaryUser}.authorizedKeys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIuYLePldOwgtFXwo0sw48rBVzX2zHjzGshFq4V9xwMLAAAABHNzaDo= somanoda@25N1103630nodasoma.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrvifm9j0kjjoEUWf+QeFxQgdA9XPYc/VRyS9oPL+X5"
    ];

    users.deploy.authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEl0CHSwhFrBL+gbMqmas4c3uXTZajD3A4Ns2xLYkgVe github-actions-deploy"
    ];
  };
in
{
  _module.args.hostData = hostData;
}
