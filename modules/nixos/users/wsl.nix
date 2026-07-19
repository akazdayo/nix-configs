{ pkgs, hostMeta, ... }:
let
  primaryUser = hostMeta.primaryUser;
in
{
  users.users.${primaryUser} = {
    isNormalUser = true;
    description = primaryUser;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.nushell;
  };
}
