{ ... }:
{
  programs.nixvim = {
    # LSP設定
    plugins.lsp = {
      enable = true;
      servers = {
        nixd.enable = true;
        nushell.enable = true;
        tsgo.enable = true;
        ts_ls.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };
        svelte.enable = true;
        pyrefly.enable = true;
        ruff.enable = true;
        astro.enable = true;
        gleam.enable = true;
        gopls.enable = true;
        zls.enable = true;
      };
    };

    # 診断設定（カーソル位置の警告を自動表示）
    diagnostic.settings = {
      virtual_text = true;
      float = {
        border = "rounded";
        source = true;
      };
    };

    # LSPキーマップ
    keymaps = [
      {
        mode = "n";
        key = "K";
        action.__raw = "vim.lsp.buf.hover";
        options = {
          silent = true;
          desc = "Show hover information";
        };
      }
      {
        mode = "n";
        key = "gd";
        action.__raw = "vim.lsp.buf.definition";
        options = {
          silent = true;
          desc = "Go to definition";
        };
      }
      {
        mode = "n";
        key = "<leader>ld";
        action.__raw = "function() vim.diagnostic.open_float({ scope = 'cursor' }) end";
        options = {
          silent = true;
          desc = "Show diagnostic details";
        };
      }
    ];
  };
}
