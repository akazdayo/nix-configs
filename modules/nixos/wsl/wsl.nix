{ hostMeta, ... }:
{
  networking.hostName = hostMeta.hostName;

  wsl = {
    enable = true;
    defaultUser = hostMeta.primaryUser;
    startMenuLaunchers = true;
  };
}
