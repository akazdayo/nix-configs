{ ... }:
{
  programs.nixvim = {
    plugins.lazygit.enable = true;

    keymaps = [
      {
        mode = "n";
        key = "<leader>gg";
        action = ":LazyGit<CR>";
        options = {
          silent = true;
          desc = "Open lazygit";
        };
      }
    ];
  };
}
