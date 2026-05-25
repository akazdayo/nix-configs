{ pkgs, ... }:
{
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    stylua.enable = true;
    shfmt.enable = true;
    prettier.enable = true;
    rustfmt.enable = true;
  };
}
