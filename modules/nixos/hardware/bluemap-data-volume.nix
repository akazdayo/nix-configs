{ hostMeta, ... }:
let
  fileSystemData = hostMeta.hostData.fileSystems.bluemapData;
in
{
  fileSystems.${fileSystemData.mountPoint} = {
    device = fileSystemData.device;
    fsType = fileSystemData.fsType;
  };
}
