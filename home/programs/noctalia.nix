{ inputs, pkgs, ... }:
{
  # Noctalia Shell設定
  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    systemd.enable = true;
  };
}
