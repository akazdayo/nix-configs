{ hostMeta, ... }:
let
  hostData = hostMeta.hostData;
  primaryInterface =
    hostData.networking.primaryInterface
      or (throw "hostData.networking.primaryInterface must be set for OpenStack host");
in
{
  networking.hostName = hostMeta.hostName;
  networking.networkmanager.enable = true;
  networking.interfaces.${primaryInterface}.useDHCP = true;

  # First-boot userdata comes from infra/openstack/user-data.sh.tftpl via the
  # base NixOS OpenStack image's openstack-config/amazon-init service.
  # Avoid enabling cloud-init here to prevent dual metadata engines from
  # racing on the same config-drive.
  services.cloud-init.enable = false;

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
