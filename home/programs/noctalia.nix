{ inputs, pkgs, ... }:
{
  # Noctalia Shell設定
  programs.noctalia-shell = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    systemd.enable = false;
  };
}
