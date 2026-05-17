{ config, hostMeta, lib, ... }:
let
  cloudflaredData = hostMeta.hostData.cloudflared;
in
{
  services.cloudflared = {
    enable = true;

    tunnels.${cloudflaredData.tunnelUuid} = {
      credentialsFile = config.sops.secrets.cloudflared-credentials.path;
      default = "http_status:404";
      edgeIPVersion = "auto";

      ingress = lib.mapAttrs'
        (_: svc: lib.nameValuePair svc.hostname svc.service)
        cloudflaredData.ingress;
    };
  };
}
