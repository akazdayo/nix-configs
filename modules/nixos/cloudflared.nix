{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.local.cloudflared;
  cloudflaredWrapper = pkgs.writeShellScriptBin "cloudflared" ''
    if [ "$1" = "tunnel" ]; then
      exec ${pkgs-unstable.cloudflared}/bin/cloudflared "$@" --protocol http2
    fi

    exec ${pkgs-unstable.cloudflared}/bin/cloudflared "$@"
  '';
in
{
  options.local.cloudflared = {
    tunnelUuid = lib.mkOption { type = lib.types.str; };
    credentialsSopsFile = lib.mkOption { type = lib.types.path; };
    ingress = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            hostname = lib.mkOption { type = lib.types.str; };
            service = lib.mkOption { type = lib.types.str; };
          };
        }
      );
    };
  };

  config = {
    sops.secrets.cloudflared-credentials = {
      sopsFile = cfg.credentialsSopsFile;
      owner = "root";
      mode = "0400";
    };

    services.cloudflared = {
      enable = true;
      package = cloudflaredWrapper;
      tunnels.${cfg.tunnelUuid} = {
        credentialsFile = config.sops.secrets.cloudflared-credentials.path;
        default = "http_status:404";
        edgeIPVersion = "auto";
        ingress = lib.mapAttrs' (_: svc: lib.nameValuePair svc.hostname svc.service) cfg.ingress;
      };
    };
  };
}
