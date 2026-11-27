{ inputs, nixvim-module, ... }:
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
    nixpkgs.source = inputs.nixpkgs;
  };
}
