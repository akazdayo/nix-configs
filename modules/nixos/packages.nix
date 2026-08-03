{
  pkgs,
  pkgs-unstable,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    vim
    pkgs-unstable.cloudflared
  ];
}
