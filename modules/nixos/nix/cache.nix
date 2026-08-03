{ config, lib, ... }:
let
  cfg = config.local.nix.cache;
in
{
  options.local.nix.cache = {
    substituters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    trustedPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    alwaysAllowSubstitutes = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config.nix.settings = {
    extra-substituters = cfg.substituters;
    extra-trusted-public-keys = cfg.trustedPublicKeys;
    always-allow-substitutes = cfg.alwaysAllowSubstitutes;
  };
}
