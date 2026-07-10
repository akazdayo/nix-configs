{
  hostMeta,
  lib,
  pkgs,
  ...
}:
let
  blueMapData = hostMeta.hostData.bluemap or { };
  webRoot = blueMapData.webRoot or "/srv/bluemap/web";
  httpPort = blueMapData.httpPort or 80;
  rsyncPort = blueMapData.rsyncPort or 873;
  rsyncModule = blueMapData.rsyncModule or "bluemap-web";
  rsyncAllowedHosts = blueMapData.rsyncAllowedHosts or [ ];
  rsyncConfig = pkgs.writeText "bluemap-rsyncd.conf" ''
    pid file = /run/bluemap-rsyncd.pid
    use chroot = false
    read only = false
    list = false
    uid = root
    gid = root
    hosts allow = ${lib.concatStringsSep " " rsyncAllowedHosts}
    hosts deny = *

    [${rsyncModule}]
      path = ${webRoot}
      comment = BlueMap web output
  '';
in
{
  systemd.tmpfiles.rules = [
    "d ${webRoot} 0755 root root -"
  ];

  services.caddy = {
    enable = true;
    virtualHosts.":${toString httpPort}".extraConfig = ''
      root * ${webRoot}
      file_server
    '';
  };

  systemd.services.bluemap-rsyncd = {
    description = "BlueMap rsync receiver";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.rsync}/bin/rsync --daemon --no-detach --port=${toString rsyncPort} --config=${rsyncConfig}";
      Restart = "on-failure";
      RuntimeDirectory = "bluemap-rsyncd";
    };
  };

  networking.firewall.allowedTCPPorts = [
    httpPort
    rsyncPort
  ];
}
