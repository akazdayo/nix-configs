{ ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      theme = "noctalia";
      themes.noctalia = {
        bg = [
          7
          7
          34
        ];
        black = [
          7
          7
          34
        ];
        blue = [
          169
          174
          254
        ];
        cyan = [
          155
          254
          206
        ];
        fg = [
          243
          237
          247
        ];
        green = [
          155
          254
          206
        ];
        magenta = [
          169
          174
          254
        ];
        orange = [
          255
          245
          155
        ];
        red = [
          253
          70
          99
        ];
        white = [
          243
          237
          247
        ];
        yellow = [
          255
          245
          155
        ];
      };
      default_shell = "nu";
      mouse_mode = false;
      copy_on_select = true;
      scrollback_editor = "nvim";
      keybinds.pane._children = [
        {
          bind = {
            _args = [
              "h"
              "Left"
            ];
            MoveFocus = [ "Left" ];
          };
        }
        {
          bind = {
            _args = [
              "j"
              "Down"
            ];
            MoveFocus = [ "Down" ];
          };
        }
        {
          bind = {
            _args = [
              "k"
              "Up"
            ];
            MoveFocus = [ "Up" ];
          };
        }
        {
          bind = {
            _args = [
              "l"
              "Right"
            ];
            MoveFocus = [ "Right" ];
          };
        }
      ];
    };
  };
}
