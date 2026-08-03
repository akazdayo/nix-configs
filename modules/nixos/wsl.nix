{ config, lib, ... }:
{
  options.local.wsl.defaultUser = lib.mkOption { type = lib.types.str; };

  config.wsl = {
    enable = true;
    defaultUser = config.local.wsl.defaultUser;
    startMenuLaunchers = true;
  };
}
