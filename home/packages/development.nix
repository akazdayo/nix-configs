{
  pkgs,
  pkgs-unstable,
  hostMeta,
  ...
}:
let
  isDesktop = hostMeta.platform == "nixos" && hostMeta.role == "desktop";
in
{
  home.packages = (
    if isDesktop then
      (with pkgs; [
        (unityhub.override {
          # Unity 6's shader compiler (libdxcompiler) needs libtinfo.so.6.
          extraLibs = pkgs: [ pkgs.ncurses ];
        })
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
