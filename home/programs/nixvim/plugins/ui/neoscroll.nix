{ ... }:
{
  programs.nixvim = {
    plugins.neoscroll = {
      enable = true;
      settings = {
        mappings = [
          "<C-u>"
          "<C-d>"
          "<C-b>"
          "<C-f>"
          "<C-y>"
          "<C-e>"
          "zt"
          "zz"
          "zb"
          "gg"
          "G"
        ];
        easing = "sine";
        duration_multiplier = 1.0;
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "{";
        action.__raw = ''
          function()
            local before = vim.fn.winsaveview()
            vim.cmd("normal! {")
            local target = vim.fn.winsaveview()
            local delta = target.topline - before.topline
            if delta == 0 then
              return
            end
            target.topline = before.topline
            vim.fn.winrestview(target)
            require("neoscroll").scroll(delta, { move_cursor = false, duration = 120, easing = "sine" })
          end
        '';
        options = {
          silent = true;
          desc = "Smooth previous paragraph";
        };
      }
      {
        mode = "n";
        key = "}";
        action.__raw = ''
          function()
            local before = vim.fn.winsaveview()
            vim.cmd("normal! }")
            local target = vim.fn.winsaveview()
            local delta = target.topline - before.topline
            if delta == 0 then
              return
            end
            target.topline = before.topline
            vim.fn.winrestview(target)
            require("neoscroll").scroll(delta, { move_cursor = false, duration = 120, easing = "sine" })
          end
        '';
        options = {
          silent = true;
          desc = "Smooth next paragraph";
        };
      }
    ];
  };
}
