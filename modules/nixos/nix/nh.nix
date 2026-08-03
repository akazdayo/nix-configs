{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.local.nh.flake = lib.mkOption {
    type = lib.types.str;
    description = "Default flake path used by nh";
  };

  config.programs.nh = {
    enable = true;
    package = pkgs.nh;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = config.local.nh.flake;
  };
}
