{ hostMeta, lib, ... }:
let
  caddyData = hostMeta.hostData.caddy or { };
in
{
  services.caddy = {
    enable = true;
    virtualHosts = lib.mapAttrs (domain: cfg: {
      extraConfig = "reverse_proxy ${cfg.reverseProxy}";
    }) caddyData.virtualHosts or { };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
