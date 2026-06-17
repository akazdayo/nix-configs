{ pkgs, hostMeta, ... }:
let
  primaryUser = hostMeta.primaryUser;
  hostData = hostMeta.hostData;
in
{
  imports = [ ./deploy.nix ];

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
}
