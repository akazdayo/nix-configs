{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

  users.users.jellyfin.extraGroups = [
    "render"
    "video"
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = false;
    forceEncodingConfig = true;

    hardwareAcceleration = {
      enable = true;
      type = "qsv";
      device = "/dev/dri/renderD128";
    };

    transcoding = {
      enableHardwareEncoding = true;
      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
        hevc10bit = true;
        mpeg2 = true;
        vp9 = true;
      };
      hardwareEncodingCodecs.hevc = true;
    };
  };
}
