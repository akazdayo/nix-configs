{ pkgs, ... }:
{
  xdg.configFile."wivrn/config.json" = {
    force = true;
    text = builtins.toJSON {
      application = [ "${pkgs.wayvr}/bin/wayvr" ];
    };
  };
}
