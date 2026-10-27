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
        (rust-bin.stable.latest.default.override {
          extensions = [
            "rust-analyzer"
            "rustfmt"
            "clippy"
          ];
        })
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
        google-cloud-sdk
      ])
    else
      (with pkgs; [
        (rust-bin.stable.latest.default.override {
          extensions = [
            "rust-analyzer"
            "rustfmt"
            "clippy"
          ];
        })
        pkgs-unstable.pnpm
        bun
        nodejs_24
        google-cloud-sdk
      ])
  );
}
