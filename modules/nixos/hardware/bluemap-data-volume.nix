{
  config,
  hostMeta,
  utils,
  ...
}:
let
  fileSystemData = hostMeta.hostData.fileSystems.bluemapData;
  escapedMount = utils.escapeSystemdPath fileSystemData.mountPoint;
  label = fileSystemData.label;
in
{
  disko.devices.disk.bluemap-data = {
    type = "disk";
    device = fileSystemData.diskDevice;
    content = {
      type = "filesystem";
      format = fileSystemData.fsType;
      mountpoint = fileSystemData.mountPoint;
      extraArgs = [
        "-L"
        label
      ];
    };
  };

  systemd.services.bluemap-data-disko-format = {
    description = "Format the BlueMap data volume with disko";
    wantedBy = [ "${escapedMount}.mount" ];
    before = [ "${escapedMount}.mount" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = "${config.system.build.formatScript}";
  };
}
