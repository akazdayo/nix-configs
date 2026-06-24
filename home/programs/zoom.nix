{
  config,
  lib,
  pkgs,
  ...
}:
let
  zoomConfig = "${config.xdg.configHome}/zoomus.conf";
in
{
  home.activation.configureZoomWaylandShare = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_file=${lib.escapeShellArg zoomConfig}

    mkdir -p "$(dirname "$config_file")"
    touch "$config_file"
    tmp_file="$(${pkgs.coreutils}/bin/mktemp "$config_file.XXXXXX")"

    ${pkgs.gawk}/bin/awk '
      BEGIN {
        in_general = 0
        saw_general = 0
        wrote_settings = 0
      }

      function write_settings() {
        if (!wrote_settings) {
          print "enableWaylandShare=true"
          print "xwayland=true"
          wrote_settings = 1
        }
      }

      /^[[:space:]]*\[General\][[:space:]]*$/ {
        if (in_general) {
          write_settings()
        }
        in_general = 1
        saw_general = 1
        print
        next
      }

      /^[[:space:]]*\[/ {
        if (in_general) {
          write_settings()
          in_general = 0
        }
        print
        next
      }

      in_general && /^[[:space:]]*(enableWaylandShare|xwayland)[[:space:]]*=/ {
        next
      }

      {
        print
      }

      END {
        if (in_general) {
          write_settings()
        } else if (!saw_general) {
          if (NR > 0) {
            print ""
          }
          print "[General]"
          print "enableWaylandShare=true"
          print "xwayland=true"
        }
      }
    ' "$config_file" > "$tmp_file"

    mv "$tmp_file" "$config_file"
  '';
}
