{ ... }:
{
  services.flatpak = {
    enable = true;
    packages = [
      "org.gnome.Snapshot"
    ];
  };
}
