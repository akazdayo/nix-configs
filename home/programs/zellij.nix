{ ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "nu";
      mouse_mode = true;
      copy_on_select = true;
      scrollback_editor = "nvim";
    };
  };
}
