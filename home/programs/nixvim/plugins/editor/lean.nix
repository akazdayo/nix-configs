{ ... }:
{
  programs.nixvim.plugins.lean = {
    enable = true;
    callSetup = false;
  };
}
