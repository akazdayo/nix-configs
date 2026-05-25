{ pkgs, hostMeta, ... }:
let
  primaryUser = hostMeta.primaryUser;
  hostData = hostMeta.hostData;
in
{
  users.users.${primaryUser} = {
    isNormalUser = true;
    description = primaryUser;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.nushell;
    openssh.authorizedKeys.keys = hostData.users.${primaryUser}.authorizedKeys;
  };

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
