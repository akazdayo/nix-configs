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
    ++ lib.optionals (hostMeta.platform == "nixos" && hostMeta.role == "desktop") [
      pkgs.mpv
      pkgs.mpvpaper
    ]
    ++ (with pkgs-unstable; [
      spotify
    ]);
}
