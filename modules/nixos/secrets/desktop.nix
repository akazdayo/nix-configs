{ pkgs, ... }:
{
  services.pcscd.enable = true;

  environment.variables.SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";

  environment.systemPackages = with pkgs; [
    age-plugin-yubikey
    age
    sops
    ssh-to-age
  ];

  sops = {
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      generateKey = false;
      plugins = with pkgs; [ age-plugin-yubikey ];
    };

    # System-level secret for the nixos desktop host.
    # Keep the encrypted file at secrets/nixos/home.yaml during the refactor.
    secrets.immich-api-key = {
      sopsFile = ../../../secrets/nixos/home.yaml;
      owner = "akazdayo";
      mode = "0400";
    };
  };
}
