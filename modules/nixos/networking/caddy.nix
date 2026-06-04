{ hostMeta, lib, ... }:
let
  caddyData = hostMeta.hostData.caddy or { };
  virtualHosts = caddyData.virtualHosts or { };

  mkVirtualHost =
    _: virtualHost:
    lib.nameValuePair virtualHost.hostname {
      extraConfig =
        virtualHost.extraConfig or ''
          reverse_proxy ${virtualHost.upstream}
        '';
    };
in
{
  services.caddy = {
    enable = virtualHosts != { };
    virtualHosts = lib.mapAttrs' mkVirtualHost virtualHosts;
  };

  networking.firewall.allowedTCPPorts = lib.unique (
    lib.flatten (
      lib.mapAttrsToList (
        _: virtualHost: virtualHost.openFirewallPorts or lib.optional (virtualHost.openFirewall or false) 80
      ) virtualHosts
    )
  );
}
