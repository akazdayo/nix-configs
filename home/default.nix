{...}: {
  imports = [
    ./programs/git.nix
    ./programs/shell.nix
    ./programs/packages.nix
    ./programs/gnome.nix
  ];

  home.stateVersion = "25.05";
}
