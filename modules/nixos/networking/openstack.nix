{ hostMeta, ... }:
let
  hostData = hostMeta.hostData;
  primaryInterface = hostData.networking.primaryInterface or "enp1s0";
in
{
  networking.hostName = hostMeta.hostName;
  networking.networkmanager.enable = true;
  networking.interfaces.${primaryInterface}.useDHCP = true;

  services.cloud-init.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
