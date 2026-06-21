{ ... }:
{
  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>d";
      action = "\"_d";
      options = {
        noremap = true;
        desc = "Delete without yanking";
      };
    }
    {
      mode = "n";
      key = "<leader>dd";
      action = "\"_dd";
      options = {
        noremap = true;
        desc = "Delete line without yanking";
      };
    }
    {
      mode = "n";
      key = "<leader>D";
      action = "\"_D";
      options = {
        noremap = true;
        desc = "Delete to end without yanking";
      };
    }
    {
      mode = "t";
      key = "<C-q>";
      action = "<C-\\><C-n>";
      options = {
        noremap = true;
        desc = "Exit terminal mode";
      };
    }
  ];
}
