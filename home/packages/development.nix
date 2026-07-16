{
  pkgs,
  pkgs-unstable,
  hostMeta,
  ...
}:
let
  isDesktop = hostMeta.hostName == "milk";
in
{
  home.packages = (
    if isDesktop then
      (with pkgs; [
        unityhub
        pkgs-unstable.pnpm
      ])
    else
      (with pkgs; [
        pkgs-unstable.pnpm
        bun
        nodejs_24
      ])
  );
}
