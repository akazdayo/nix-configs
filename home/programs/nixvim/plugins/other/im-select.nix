{
  lib,
  pkgs,
  hostMeta,
  ...
}:
let
  enableImSelect = builtins.elem hostMeta.hostName [
    "milk"
    "chiffon"
  ];
in
{
  programs.nixvim = lib.mkIf enableImSelect {
    extraPlugins = [
      pkgs.vimPlugins.im-select-nvim
    ];

    extraPackages =
      lib.optionals pkgs.stdenv.isLinux [ pkgs.fcitx5 ]
      ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.macism ];

    extraConfigLua = ''
      require("im_select").setup({
        default_im_select = vim.fn.has("macunix") == 1 and "com.apple.keylayout.ABC" or "keyboard-us",
        set_default_events = { "InsertLeave", "CmdlineLeave" },
        set_previous_events = {},
        keep_quiet_on_no_binary = true,
        async_switch_im = false,
      })
    '';
  };
}
