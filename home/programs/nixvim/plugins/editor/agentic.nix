{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "agentic.nvim";
        version = "2026-07-02";
        src = pkgs.fetchFromGitHub {
          owner = "carlos-algms";
          repo = "agentic.nvim";
          rev = "9ca49020144ba9a30d1a664a371d4627d9b87a51";
          hash = "sha256-c8NcOCjXfBAPgYtx+JVZqfOo5fzIirKx4bYbFEk1O9E=";
        };

        nvimRequireCheck = "agentic";
      })
    ];

    extraConfigLua = ''
      require("agentic").setup({
        provider = "pi-acp",
        provider_switcher = {
          hide_unhealthy_providers = true,
        },
      })
    '';

    keymaps = [
      {
        mode = [
          "n"
          "v"
          "i"
        ];
        key = "<C-\\>";
        action.__raw = ''function() require("agentic").toggle() end'';
        options = {
          silent = true;
          desc = "Toggle Agentic Chat";
        };
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<C-'>";
        action.__raw = ''function() require("agentic").add_selection_or_file_to_context() end'';
        options = {
          silent = true;
          desc = "Add file or selection to Agentic context";
        };
      }
      {
        mode = [
          "n"
          "v"
          "i"
        ];
        key = "<C-,>";
        action.__raw = ''function() require("agentic").new_session() end'';
        options = {
          silent = true;
          desc = "New Agentic session";
        };
      }
      {
        mode = [
          "n"
          "v"
          "i"
        ];
        key = "<A-i>r";
        action.__raw = ''function() require("agentic").restore_session() end'';
        options = {
          silent = true;
          desc = "Restore Agentic session";
        };
      }
      {
        mode = "n";
        key = "<leader>ad";
        action.__raw = ''function() require("agentic").add_current_line_diagnostics() end'';
        options = {
          silent = true;
          desc = "Add current line diagnostic to Agentic";
        };
      }
      {
        mode = "n";
        key = "<leader>aD";
        action.__raw = ''function() require("agentic").add_buffer_diagnostics() end'';
        options = {
          silent = true;
          desc = "Add buffer diagnostics to Agentic";
        };
      }
    ];
  };
}
