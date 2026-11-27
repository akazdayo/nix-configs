{ pkgs-unstable, ... }:
{
  programs.labwc = {
    enable = true;
    package = pkgs-unstable.labwc; # ウィンドウ共有に必要な toplevel capture は 0.20 以降
  };
}
