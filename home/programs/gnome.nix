{lib, ...}: {
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = [(lib.hm.gvariant.mkTuple ["xkb" "jp"])];
      xkb-options = ["terminate:ctrl_alt_bksp"];
    };
  };
}
