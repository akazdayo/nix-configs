{ hostMeta, ... }:
let
  hostData = hostMeta.hostData;
  primaryUser = hostMeta.primaryUser;
in
{
  users.users.deploy = {
    isNormalUser = true;
    description = "deploy-rs deployment user";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys =
      hostData.users.deploy.authorizedKeys or hostData.users.${primaryUser}.authorizedKeys;
  };

  security.sudo.extraRules = [
    {
      users = [ "deploy" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
