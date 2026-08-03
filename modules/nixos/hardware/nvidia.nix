{
  pkgs,
  config,
  ...
}:
{
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa
      egl-wayland
      nvidia-vaapi-driver # VA-API追加
      libva
      libva-utils
      config.boot.kernelPackages.nvidiaPackages.stable # NVENC/CUDA用
    ];
  };

  boot.kernelModules = [ "nvidia-uvm" ];

  hardware.nvidia-container-toolkit.enable = true;

  # Wayland用カーネルパラメータ
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];

  # NVIDIA用Wayland環境変数
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LD_LIBRARY_PATH = [ "/run/opengl-driver/lib" ];
    WLR_NO_HARDWARE_CURSORS = "1"; # NVIDIAカーソル問題回避
  };

  # NVIDIA関連のユーザー環境（ホームマネージャー経由）
  home-manager.sharedModules = [
    ({ pkgs, ... }: {
      home.packages = with pkgs; [
        nvtopPackages.nvidia
        cudaPackages.cuda_nvcc
      ];

      # optional Nvidia hardware acceleration
      programs.obs-studio.package = pkgs.obs-studio.override {
        cudaSupport = true;
      };
    })
  ];

}
