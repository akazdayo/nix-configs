{
  config,
  hostMeta,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cacheData = hostMeta.hostData.cache;
  rustfsData = cacheData.rustfs;
  rustfsPkg = inputs.niks3.packages.${pkgs.system}.rustfs;
in
{
  users.groups.rustfs = { };
  users.groups.s3-cache = { };
  users.users.rustfs = {
    isSystemUser = true;
    group = "rustfs";
    extraGroups = [ "s3-cache" ];
  };
  users.users.niks3.extraGroups = [ "s3-cache" ];

  systemd.tmpfiles.rules = [
    "d ${rustfsData.dataRoot} 0755 rustfs rustfs -"
  ];

  systemd.services.rustfs = {
    description = "RustFS S3-compatible object storage";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "rustfs-start" ''
        exec ${rustfsPkg}/bin/rustfs \
          --address ${rustfsData.listenAddress} \
          --access-key-file ${config.sops.secrets.rustfs-access-key.path} \
          --secret-key-file ${config.sops.secrets.rustfs-secret-key.path} \
          ${rustfsData.dataRoot}
      '';
      StateDirectory = "rustfs";
      User = "rustfs";
      Group = "rustfs";
      DynamicUser = lib.mkForce false;
      Restart = "on-failure";
    };
  };

  systemd.services.rustfs-setup = {
    description = "Create RustFS bucket for niks3";
    after = [ "rustfs.service" ];
    requires = [ "rustfs.service" ];
    before = [ "niks3.service" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.s5cmd ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "rustfs-setup" ''
        set -euo pipefail

        export AWS_ACCESS_KEY_ID="$(cat ${config.sops.secrets.rustfs-access-key.path})"
        export AWS_SECRET_ACCESS_KEY="$(cat ${config.sops.secrets.rustfs-secret-key.path})"
        endpoint_url="http://${rustfsData.listenAddress}"

        ready=0
        for i in $(seq 1 60); do
          if s5cmd --endpoint-url "$endpoint_url" ls 2>/dev/null; then
            ready=1
            break
          fi
          echo "Waiting for RustFS to start... ($i/60)"
          sleep 2
        done

        if [ "$ready" -eq 0 ]; then
          echo "ERROR: RustFS did not become ready after 60 attempts" >&2
          exit 1
        fi

        if ! s5cmd --endpoint-url "$endpoint_url" ls "s3://${cacheData.bucket}" >/dev/null 2>&1; then
          s5cmd --endpoint-url "$endpoint_url" mb "s3://${cacheData.bucket}"
        fi
      '';
    };
  };
}
