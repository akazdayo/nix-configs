{ config, pkgs, ... }:
{
  sops = {
    age = {
      sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      generateKey = false;
      plugins = with pkgs; [ age-plugin-yubikey ];
    };

    # Home Manager imports this module on desktop/server/darwin, but there are
    # no active HM-managed secrets yet. Keep examples aligned to current paths.
    # Example:
    # secrets.immich-api-key = {
    #   sopsFile = ../../secrets/nixos/home.yaml;
    #   path = "%r/immich-api-key";
    # };
  };

  home.file.".config/sops/age/yubikey-priority.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Always provide SSH identity as fallback
      ssh-to-age -private-key -i "$HOME"/.ssh/id_ed25519
      # If YubiKey is plugged in, also provide YubiKey identity (preferred)
      if age-plugin-yubikey --list-all &>/dev/null; then
          age-plugin-yubikey --identity 2>/dev/null
      fi
    '';
  };

  home.sessionVariables = {
    SOPS_AGE_KEY_CMD = "${config.home.homeDirectory}/.config/sops/age/yubikey-priority.sh";
  };

  home.packages = with pkgs; [
    sops
    age
    age-plugin-yubikey
    ssh-to-age
  ];
}
