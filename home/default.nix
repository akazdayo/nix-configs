{...}: {
  imports = [
    ./programs/git.nix
    ./programs/files.nix
    ./programs/packages.nix
    ./programs/gnome.nix
  ];

  home.stateVersion = "25.05";
}
