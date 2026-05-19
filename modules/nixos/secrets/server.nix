{ pkgs, ... }:
{
  services.pcscd.enable = true;

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

    secrets.atticd-env = {
      sopsFile = ../../../secrets/server/attic.yaml;
      owner = "root";
      mode = "0400";
    };

    # Server-level sops integration is configured here, but current
    # container /etc/... secret files remain legacy host-local paths.
  };
}
