{...}: {
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 24 * 1024; # 24 GB
    }
  ];
}
