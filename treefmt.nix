{ pkgs, ... }:
{
  projectRootFile = "flake.nix";

  settings.excludes = [
    "secrets/**/*.yaml"
    "secrets/**/*.yml"
  ];

  programs = {
    nixfmt.enable = true;
    stylua.enable = true;
    shfmt.enable = true;
    prettier.enable = true;
    rustfmt.enable = true;
  };
}
