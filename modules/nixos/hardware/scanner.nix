{ pkgs, hostMeta, ... }: {
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  services = {
    udev.packages = [ pkgs.sane-airscan ];
    avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };

  environment.systemPackages = with pkgs; [
    simple-scan
    sane-airscan
    sane-backends
  ];

  users.users.${hostMeta.primaryUser}.extraGroups = [
    "scanner"
    "lp"
  ];
}
