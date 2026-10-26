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
          buildFHSEnv =
            args:
            pkgs.buildFHSEnv (
              args
              // {
                profile = (args.profile or "") + ''
                  export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.ncurses ]}:''${LD_LIBRARY_PATH:-}"
                '';
              }
            );
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
