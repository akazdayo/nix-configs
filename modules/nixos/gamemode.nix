{ pkgs, ... }:
{
  # Steam launch options: gamemoderun %command%
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        desiredgov = "performance";
        renice = 5; # GameMode applies nice -5 while the game is running.
        ioprio = 0;
        softrealtime = "off";
        inhibit_screensaver = 1;
        disable_splitlock = 0;
      };
      cpu = {
        pin_cores = "no";
        park_cores = "no";
      };
    };
  };

  programs.steam.extraPackages = [ pkgs.gamemode ];
}
