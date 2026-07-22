{ hostMeta, ... }:
{
  swapDevices = [
    {
      device = hostMeta.hostData.swap.device;
      size = hostMeta.hostData.swap.size or (2 * 1024);
    }
  ];
}
