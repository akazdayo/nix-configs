{
  inputs,
  pkgs,
  hostMeta,
  ...
}:
{
  home.packages = with pkgs; [
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
    xdg-utils
    libreoffice
    signal-desktop
    tor-browser
    google-chrome
    nautilus
    unar
    obsidian
    vesktop
    chromium
    awww
    #inputs.kopuz.packages.${hostMeta.system}.default
    baobab
  ];
}
