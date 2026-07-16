{
  lib,
  pkgs,
  pkgs-unstable,
  hostMeta,
  ...
}:
{
  home.packages =
    (with pkgs; [
      gimp
      kooha
      yt-dlp
      ffmpeg
      vlc
    ])
    ++ lib.optionals (hostMeta.hostName == "milk") [
      pkgs.mpv
      pkgs.mpvpaper
    ]
    ++ (with pkgs-unstable; [
      spotify
    ]);
}
