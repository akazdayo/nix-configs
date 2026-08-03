{ config, lib, ... }:
let
  cfg = config.local.wakatime;
in
{
  options.local.wakatime = {
    sopsFile = lib.mkOption { type = lib.types.path; };
    owner = lib.mkOption { type = lib.types.str; };
  };

  config.sops.secrets.wakatime-api-key = {
    inherit (cfg) sopsFile owner;
    key = "api-key";
    mode = "0400";
  };
}
