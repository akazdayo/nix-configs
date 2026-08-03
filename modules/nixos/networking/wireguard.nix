{ config, lib, ... }:
let
  cfg = config.local.networking.wireguard;
in
{
  options.local.networking.wireguard = {
    sopsFile = lib.mkOption { type = lib.types.path; };
    secretKey = lib.mkOption { type = lib.types.str; };
    interface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
    };
    ips = lib.mkOption { type = lib.types.listOf lib.types.str; };
    peers = lib.mkOption { type = lib.types.listOf lib.types.attrs; };
  };

  config = {
    sops.secrets.local-wireguard-private-key = {
      inherit (cfg) sopsFile;
      key = cfg.secretKey;
      owner = "root";
      mode = "0400";
    };

    networking.wireguard.interfaces.${cfg.interface} = {
      inherit (cfg) ips peers;
      privateKeyFile = config.sops.secrets.local-wireguard-private-key.path;
    };
  };
}
