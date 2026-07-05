{ config, ... }:
{
  sops.secrets.maril-wireguard-private-key = {
    sopsFile = ../../../secrets/common/wireguard.yaml;
    key = "maril_wireguard_sk";
    owner = "root";
    mode = "0400";
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.0.10.3/24" ];
    privateKeyFile = config.sops.secrets.maril-wireguard-private-key.path;
    peers = [
      {
        publicKey = "p0cQLr7R7xqDYHH/eZSz2wAMjJGF+NGLFocMXXs/dEQ=";
        endpoint = "maril.blue:51821";
        allowedIPs = [ "10.0.10.0/24" ];
        persistentKeepalive = 25;
      }
    ];
  };
}
