{
  config,
  lib,
  pkgs,
  nixosConfig,
  ...
}:
{
  options.local.labwc.outputModes = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    description = "Output names and display modes to apply when labwc starts.";
  };

  config = {
    systemd.user.services.labwc-fcitx5 = {
      Unit = {
        Description = "Fcitx5 for labwc";
        PartOf = [ "labwc-session.target" ];
        After = [ "labwc-session.target" ];
      };
      Service = {
        ExecStart = lib.getExe nixosConfig.i18n.inputMethod.package;
        Restart = "on-failure";
      };
      Install.WantedBy = [ "labwc-session.target" ];
    };

    systemd.user.targets.labwc-session = {
      Unit = {
        Description = "labwc desktop session";
        PartOf = [ "graphical-session.target" ];
      };
    };

    xdg.configFile = {
      "labwc/autostart" = {
        executable = true;
        text = ''
          #!${pkgs.runtimeShell}
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE LABWC_PID XCURSOR_SIZE XCURSOR_THEME
          ${pkgs.systemd}/bin/systemctl --user start labwc-session.target
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              output: mode:
              "${pkgs.wlr-randr}/bin/wlr-randr ${
                lib.escapeShellArgs [
                  "--output"
                  output
                  "--mode"
                  mode
                ]
              }"
            ) config.local.labwc.outputModes
          )}
        '';
      };
      "labwc/shutdown" = {
        executable = true;
        text = ''
          #!${pkgs.runtimeShell}
          ${pkgs.systemd}/bin/systemctl --user stop labwc-session.target
        '';
      };
      "labwc/rc.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <labwc_config>
          <core><gap>10</gap></core>
          <desktops number="4" />
          <keyboard>
            <default />
            <keybind key="W-1"><action name="GoToDesktop" to="1" /></keybind>
            <keybind key="W-2"><action name="GoToDesktop" to="2" /></keybind>
            <keybind key="W-3"><action name="GoToDesktop" to="3" /></keybind>
            <keybind key="W-4"><action name="GoToDesktop" to="4" /></keybind>
            <keybind key="W-S-1"><action name="SendToDesktop" to="1" /></keybind>
            <keybind key="W-S-2"><action name="SendToDesktop" to="2" /></keybind>
            <keybind key="W-S-3"><action name="SendToDesktop" to="3" /></keybind>
            <keybind key="W-S-4"><action name="SendToDesktop" to="4" /></keybind>
            <keybind key="W-Return"><action name="Execute" command="ghostty" /></keybind>
            <keybind key="W-d"><action name="Execute" command="noctalia msg panel-toggle launcher" /></keybind>
            <keybind key="W-space"><action name="Execute" command="noctalia msg panel-toggle launcher" /></keybind>
            <keybind key="W-s"><action name="Execute" command="noctalia msg panel-toggle control-center" /></keybind>
            <keybind key="W-comma"><action name="Execute" command="noctalia msg settings-toggle" /></keybind>
            <keybind key="W-Escape"><action name="Execute" command="noctalia msg panel-toggle session" /></keybind>
            <keybind key="W-S-e"><action name="Exit" /></keybind>
            <keybind key="Print"><action name="Execute" command="flameshot gui" /></keybind>
            <keybind key="C-Print"><action name="Execute" command="flameshot screen --clipboard" /></keybind>
            <keybind key="A-Print"><action name="Execute" command="flameshot full --clipboard" /></keybind>
            <keybind key="XF86AudioRaiseVolume"><action name="Execute" command="noctalia msg volume-up" /></keybind>
            <keybind key="XF86AudioLowerVolume"><action name="Execute" command="noctalia msg volume-down" /></keybind>
            <keybind key="XF86AudioMute"><action name="Execute" command="noctalia msg volume-mute" /></keybind>
            <keybind key="XF86MonBrightnessUp"><action name="Execute" command="noctalia msg brightness-up" /></keybind>
            <keybind key="XF86MonBrightnessDown"><action name="Execute" command="noctalia msg brightness-down" /></keybind>
          </keyboard>
          <mouse><default /></mouse>
        </labwc_config>
      '';
    };
  };
}
