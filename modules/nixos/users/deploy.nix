{ config, lib, ... }:
let
  cfg = config.local.users.deploy;
in
{
  options.local.users.deploy.authorizedKeys = lib.mkOption {
    type = lib.types.listOf lib.types.str;
  };

  config = {
    users.users.deploy = {
      isNormalUser = true;
      description = "deploy-rs deployment user";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
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
  };
}
