{ hostMeta, ... }:
let
  fileSystemData = hostMeta.hostData.fileSystems.minecraftData;
in
{
  fileSystems.${fileSystemData.mountPoint} = {
    device = fileSystemData.device;
    fsType = fileSystemData.fsType;
  };
}
