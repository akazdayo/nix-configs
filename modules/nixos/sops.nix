{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.sops;
in
{
  options.local.sops = {
    pcscd = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    yubikeyPlugin = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    keyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    ageKeyFileEnvironment = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    ageKeyCommandEnvironment = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = {
    services.pcscd.enable = cfg.pcscd;
    environment.systemPackages =
      (with pkgs; [
        age
        sops
        ssh-to-age
      ])
      ++ lib.optional cfg.yubikeyPlugin pkgs.age-plugin-yubikey;
    environment.variables =
      lib.optionalAttrs (cfg.ageKeyFileEnvironment != null) {
        SOPS_AGE_KEY_FILE = cfg.ageKeyFileEnvironment;
      }
      // lib.optionalAttrs (cfg.ageKeyCommandEnvironment != null) {
        SOPS_AGE_KEY_CMD = cfg.ageKeyCommandEnvironment;
      };
    sops.age = {
      inherit (cfg) keyFile;
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      generateKey = false;
      plugins = lib.optional cfg.yubikeyPlugin pkgs.age-plugin-yubikey;
    };
  };
}
