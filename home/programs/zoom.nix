{ ... }:
{
  xdg.configFile."zoomus.conf".text = ''
    [General]
    enableWaylandShare=true
    xwayland=true
  '';
}
