{ config, pkgs, ... }:
{
  services.pcscd.enable = true;

  environment.variables.SOPS_AGE_KEY_CMD = "$HOME/.config/sops/age/yubikey-priority.sh";

  environment.systemPackages = with pkgs; [
    age-plugin-yubikey
    age
    sops
    ssh-to-age
  ];

  sops = {
    age = {
      keyFile = "/home/akazdayo/.config/sops/age/keys.txt";
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      generateKey = false;
      plugins = with pkgs; [ age-plugin-yubikey ];
    };

    secrets.cloudflared-credentials = {
      sopsFile = ../../../secrets/server/cloudflared.yaml;
      owner = "root";
      mode = "0400";
    };

    secrets.rustfs-access-key = {
      sopsFile = ../../../secrets/server/rustfs.yaml;
      owner = "root";
      mode = "0400";
    };

    secrets.rustfs-secret-key = {
      sopsFile = ../../../secrets/server/rustfs.yaml;
      owner = "root";
      mode = "0400";
    };

    templates."rustfs-env".content = ''
      RUSTFS_ACCESS_KEY=${config.sops.placeholder.rustfs-access-key}
      RUSTFS_SECRET_KEY=${config.sops.placeholder.rustfs-secret-key}
    '';

    secrets.niks3-api-token = {
      sopsFile = ../../../secrets/server/niks3.yaml;
      owner = "root";
      mode = "0400";
    };

    secrets.niks3-signing-key = {
      sopsFile = ../../../secrets/server/niks3.yaml;
      owner = "root";
      mode = "0400";
    };

    secrets.niks3-s3-access-key = {
      sopsFile = ../../../secrets/server/niks3.yaml;
      owner = "root";
      mode = "0400";
    };

    secrets.niks3-s3-secret-key = {
      sopsFile = ../../../secrets/server/niks3.yaml;
      owner = "root";
      mode = "0400";
    };

    # Server-level sops integration is configured here, but current
    # container /etc/... secret files remain legacy host-local paths.
  };
}
