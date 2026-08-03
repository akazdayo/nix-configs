{ config, lib, ... }:
let
  cfg = config.local.caddy;
  mkVirtualHost =
    _: virtualHost:
    lib.nameValuePair virtualHost.hostname {
      extraConfig =
        if virtualHost.extraConfig != null then
          virtualHost.extraConfig
        else
          "reverse_proxy ${virtualHost.upstream}";
    };
in
{
  options.local.caddy.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          hostname = lib.mkOption { type = lib.types.str; };
          upstream = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
          extraConfig = lib.mkOption {
            type = lib.types.nullOr lib.types.lines;
            default = null;
          };
          openFirewallPorts = lib.mkOption {
            type = lib.types.listOf lib.types.port;
            default = [ ];
          };
          openFirewall = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
      }
    );
  };

  config = {
    services.caddy = {
      enable = true;
      virtualHosts = lib.mapAttrs' mkVirtualHost cfg.virtualHosts;
    };
    networking.firewall.allowedTCPPorts = lib.unique (
      lib.flatten (
        lib.mapAttrsToList (
          _: virtualHost: virtualHost.openFirewallPorts ++ lib.optional virtualHost.openFirewall 80
        ) cfg.virtualHosts
      )
    );
  };
}
