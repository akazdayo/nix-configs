{ hostMeta, ... }:
let
  hostData = hostMeta.hostData;
in
{
  imports = [
    ./tailscale.nix
    ./macvlan-shim.nix
    ./cloudflared.nix
  ];

  networking.hostName = hostMeta.hostName;
  networking.nameservers = hostData.networking.nameservers;
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = hostData.networking.unmanagedInterfaces;

  networking.interfaces.${hostData.networking.primaryInterface} = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = hostData.networking.address;
        prefixLength = hostData.networking.prefixLength;
      }
    ];
  };
  networking.defaultGateway = hostData.networking.defaultGateway;
  services.nscd.enableNsncd = true;

  # SSH
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
