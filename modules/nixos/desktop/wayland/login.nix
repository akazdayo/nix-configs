{ ... }:
{
  services.displayManager.ly = {
    enable = true;
    x11Support = false;
    settings = {
      load = false;
      save = false;
    };
  };
}
