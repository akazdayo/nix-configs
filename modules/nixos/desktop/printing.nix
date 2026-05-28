{ ... }:
{
  services.printing = {
    enable = true;
    webInterface = true;
    browsed.enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
