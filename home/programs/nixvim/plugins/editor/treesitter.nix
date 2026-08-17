{ config, pkgs, ... }:
{
  # シンタックスハイライト
  programs.nixvim.plugins.treesitter = {
    enable = true;
    grammarPackages = config.programs.nixvim.plugins.treesitter.package.allGrammars ++ [
      pkgs.tree-sitter-grammars.tree-sitter-spade
    ];
    languageRegister.spade = "spade";
    settings = {
      highlight.enable = true;
      indent.enable = true;
    };
  };
}
