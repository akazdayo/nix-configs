{ pkgs, ... }:
{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;

    settings = {
      format_on_save = {
        lsp_format = "fallback";
        timeout_ms = 500;
      };

      formatters_by_ft = {
        nix = [ "nixfmt" ];
        lua = [ "stylua" ];
        python = [ "ruff_format" ];
        rust = [ "rustfmt" ];
        sh = [ "shfmt" ];
        markdown = [
          "prettierd"
          "prettier"
        ];
        "_" = [ "trim_whitespace" ];
      };

      formatters = {
        treefmt = {
          require_cwd = false;
        };
      };
    };

    autoInstall = {
      enable = true;
      overrides = {
        "treefmt" = null;
      };
    };
  };
}
