{ pkgs, ... }:
{
  programs.nixvim = {
    # LSP設定
    plugins.lsp = {
      enable = true;
      servers = {
        nixd.enable = true;
        nushell.enable = true;
        vtsls.enable = true;
        vue_ls = {
          enable = true;
          tslsIntegration = false;
        };
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };
        svelte.enable = true;
        pyrefly.enable = true;
        ruff.enable = true;
        astro = {
          enable = true;
          # Nixpkgs' astro-language-server package does not expose its
          # TypeScript devDependency to Node's module resolver.
          cmd = [
            "${pkgs.coreutils}/bin/env"
            "NODE_PATH=${pkgs.typescript}/lib/node_modules"
            "astro-ls"
            "--stdio"
          ];
          extraOptions.init_options.typescript.tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib";
        };
        gleam.enable = true;
        gopls.enable = true;
        verible.enable = true;
        zls.enable = true;
      };
    };

    lsp.servers.spade = {
      enable = true;
      package = pkgs.spade;
      config = {
        cmd = [ "${pkgs.spade}/bin/spade-language-server" ];
        filetypes = [ "spade" ];
        root_markers = [ "swim.toml" ];
      };
    };

    extraConfigLua = ''
      vim.filetype.add({ extension = { spade = "spade" } })
    '';

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
