{ ... }:
{
  programs.nixvim = {
    plugins.toggleterm = {
      enable = true;
      settings = {
        direction = "float";
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>t";
        action = "<cmd>ToggleTerm<cr>";
        options = {
          silent = true;
          desc = "Toggle floating terminal";
        };
      }
    ];
  };
}
