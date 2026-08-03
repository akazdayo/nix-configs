{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.users.primary;
in
{
  options.local.users.primary = {
    name = lib.mkOption { type = lib.types.str; };
    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    trustedNixUser = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = {
    users.users.${cfg.name} = {
      isNormalUser = true;
      description = cfg.name;
      inherit (cfg) extraGroups;
      shell = pkgs.nushell;
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };

    nix.settings.trusted-users = lib.optionals cfg.trustedNixUser [ cfg.name ];
  };
}
