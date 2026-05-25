{
  config,
  hostMeta,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cloudflaredData = hostMeta.hostData.cloudflared;
  cloudflaredWrapper = pkgs.writeShellScriptBin "cloudflared" ''
    if [ "$1" = "tunnel" ]; then
      exec ${pkgs-unstable.cloudflared}/bin/cloudflared "$@" --protocol http2
    fi

    exec ${pkgs-unstable.cloudflared}/bin/cloudflared "$@"
  '';
in
{
  services.cloudflared = {
    enable = true;
    package = cloudflaredWrapper;

    tunnels.${cloudflaredData.tunnelUuid} = {
      credentialsFile = config.sops.secrets.cloudflared-credentials.path;
      default = "http_status:404";
      edgeIPVersion = "auto";

      ingress = lib.mapAttrs' (
        _: svc: lib.nameValuePair svc.hostname svc.service
      ) cloudflaredData.ingress;
    };
  };
}
