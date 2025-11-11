{pkgs, ...}: {
  imports = [
    ../../hardware-configuration.nix
    ../../modules/boot
    ../../modules/networking
    ../../modules/locale
    ../../modules/desktop
    ../../modules/hardware
    ../../modules/audio
    ../../modules/users
    ../../modules/gaming
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  nixpkgs.config.allowUnfree = true;

  programs.firefox.enable = true;

  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    vim
  ];

  system.stateVersion = "25.05";
}
