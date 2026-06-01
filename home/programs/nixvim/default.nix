{ nixvim-module, pkgs, ... }:
{
  imports = [
    nixvim-module
    ./opts.nix
    ./keymaps.nix
    ./colorscheme.nix
    ./plugins
    ./lsp.nix
  ];

  programs.nixvim = {
    enable = true;
    version.enableNixpkgsReleaseCheck = false;
    nixpkgs.source = pkgs.path;
  };
}
