{pkgs, ...}: {
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa
      egl-wayland
    ];
  };

  boot.kernelModules = ["nvidia-uvm"];
}
