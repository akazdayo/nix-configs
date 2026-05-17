{ hostMeta, ... }:
let
  hostData = hostMeta.hostData;
in
{
  imports = [
    ./tailscale.nix
  ];

  networking.hostName = hostMeta.hostName;
  networking.nameservers = hostData.networking.nameservers;
  networking.networkmanager.enable = true;
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
