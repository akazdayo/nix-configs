{
  lib,
  pkgs,
  pkgs-unstable,
  hostMeta,
  ...
}:
{
  home.packages = (
    with pkgs;
    [
      gimp
      kooha
      yt-dlp
      ffmpeg
      vlc
    ]
  );
}
