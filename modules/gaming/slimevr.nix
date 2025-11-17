{
  config,
  lib,
  pkgs,
  ...
}: let
  # SlimeVRパッケージにwebkit2gtk用の環境変数を設定したラッパー
  slimevr-wrapped = pkgs.symlinkJoin {
    name = "slimevr-wrapped";
    paths = [pkgs.slimevr];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/slimevr \
        --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
        --set WEBKIT_DISABLE_COMPOSITING_MODE 1 \
        --set GDK_BACKEND x11
    '';
  };
in {
  # ラップされたSlimeVRをシステムパッケージとして追加
  environment.systemPackages = [slimevr-wrapped];

  # SlimeVRトラッカー検出用のudevルール
  services.udev.packages = [pkgs.slimevr];
}
