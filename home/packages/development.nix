{
  pkgs,
  pkgs-unstable,
  ...
}:
{
  home.packages = (
    with pkgs;
    [
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
      bun
      nodejs_24
    ]
  );
}
