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
      pkgs-unstable.pnpm
      google-cloud-sdk
      bun
      nodejs_24
    ]
  );
}
