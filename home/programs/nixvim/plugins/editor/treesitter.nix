{ config, ... }:
{
  # シンタックスハイライト
  programs.nixvim.plugins.treesitter = {
    enable = true;
    grammarPackages = config.programs.nixvim.plugins.treesitter.package.allGrammars;
    settings = {
      highlight.enable = true;
      indent.enable = true;
    };
  };
}
