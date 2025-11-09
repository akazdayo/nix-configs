{...}: {
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
  };

  hardware.graphics.enable = true;
  boot.kernelModules = ["nvidia-uvm"];
}
